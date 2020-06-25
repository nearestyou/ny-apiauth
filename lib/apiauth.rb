require 'jwt'
class ApiAuth
class << self

ALGORITHM = 'HS256'
STRUCTURE = {'company_id' => nil, 'admin' => nil}
DT = 10

def key_error(key_id)
  return 'no_such_key' if ENV[key_id].nil?
  return 'invalid_key' unless key_id.end_with?('_NY_API_KEY')
  false
end

def generate(slug, user, key_id = 'CUBITLAS_API_KEY', admin_roles = nil)
  if ke = key_error(key_id)
    return {api_auth_token: ke, invalid_tkn: 1}
  end
  payload = STRUCTURE.clone
  payload['company_id'] = slug
  payload['auth_time'] = Time.now.to_i
  payload['admin'] = case
  when user.admin
    'admin'
  when(admin_roles.present? and admin_roles.include?(user.role))
    'admin'
  else
    ''
  end
  exp_payload = {data: payload, exp: Time.now.to_i + DT}
  {api_auth_token: JWT.encode(exp_payload, ENV[key_id], ALGORITHM), valid_tkn: 1, key_id: key_id}
end

def recover_payload(params)
  if ke = key_error(params[:key_id])
    return STRUCTURE.merge({'disallowed' => 1, 'reason' => ke})
  end
  decoded = JWT.decode params[:api_auth_token], ENV[params[:key_id]], true, {algorigthm: ALGORITHM}
    allowed_keys = STRUCTURE.keys
    decoded.first['data'].slice(*allowed_keys).merge({'allowed' => 1})
rescue JWT::VerificationError
  STRUCTURE.merge({'disallowed' => 1, 'reason' => 'verification_error'})
rescue JWT::ExpiredSignature
  STRUCTURE.merge({'disallowed' => 1, 'reason' => 'signature_expired'})
end

end
end
