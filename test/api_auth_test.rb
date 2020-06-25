require 'jwt'
require 'ostruct'
require 'byebug'
load "test/test_helper.rb"


class ApiAuthTest < Minitest::Test
  def setup
    @u = OpenStruct.new
    @u.admin = true
    @company = 'pk'
  end

  def test_missing_key
    key_id = 'asdf'
    ENV[key_id] = nil
    tkn = ApiAuth.generate(@company, @u, key_id);
    assert tkn[:api_auth_token] == 'no_such_key'
  end 

  def test_invalid_key
    key_id = 'asdf'
    ENV[key_id] = 'asdfasdf'
    tkn = ApiAuth.generate(@company, @u, key_id);
    assert tkn[:api_auth_token] == 'invalid_key'
  end 

  def test_successful_auth
    setup
    key_id = 'asdf_NY_API_KEY'
    ENV[key_id] = 'asdfasdf'
    params = ApiAuth.generate(@company, @u, key_id);
    payload = ApiAuth.recover_payload(params)
    assert payload['allowed'] == 1
    assert payload['disallowed'] == nil
    assert payload['company_id'] == @company
    assert payload['admin'] == (@u.admin ? 'admin' : nil)
  end

  def test_unsuccessful_auth
    setup
    key_id = 'asdf_NY_API_KEY'
    ENV[key_id] = 'asdfasdf'
    params = ApiAuth.generate(@company, @u, key_id);
    ENV[key_id] = 'qwerqwer'
    payload = ApiAuth.recover_payload(params)
    assert payload['allowed'] == nil
    assert payload['disallowed'] == 1
    assert payload['reason'] == 'verification_error'
  end
end
