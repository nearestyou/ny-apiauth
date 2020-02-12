class ApiAuth
class << self

def generate(slug, user, key_id, admin_roles = [])
  salt = SecureRandom.hex
  t = Time.now.to_i.to_s
  admin = case
  when user.admin
    true
  when admin_roles.include?(user.role)
    true
  else
    ''
  end
  auth_token = Digest::SHA256.new.hexdigest(slug + admin + salt + t + ENV[key_id])
  {auth_token: auth_token, auth_time: t, company_id: slug, salt: salt, admin: admin}
end

def authenticate(params)
  Digest::SHA256.new.hexdigest(params[:company_id] + (params[:admin] || '') + params[:salt] + params[:auth_time] + ENV[params[:key_id]]) == params[:auth_token] and Time.now.to_i - params[:auth_time].to_i < 10
end

end
end
