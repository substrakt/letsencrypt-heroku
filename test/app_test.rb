require_relative 'test_helper'

class AppTest < MiniTest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    ENV['AUTH_TOKEN'] = 'secrettoken'
  end

  def test_certificate_request_post
    post '/certificate_request', { auth_token: 'secrettoken' }
    assert last_response.unprocessable?
  end

  def test_certificate_request_with_correct_params
    valid_params = {
      domains: ['substrakt.com', 'www.substrakt.com'],
      heroku_app_name: ['substrakt-live'],
      zone: ['substrakt.com'],
      auth_token: 'secrettoken'
    }
    post '/certificate_request', valid_params
    assert last_response.ok?
  end

  def test_certificate_missing_domain_list
    invalid_params = {
      heroku_app_name: ['substrakt-live'],
      auth_token: 'secrettoken'
    }
    post '/certificate_request', invalid_params
    assert last_response.unprocessable?
  end

  def test_certificate_missing_heroku_app_name
    invalid_params = {
      domains: ['substrakt.com', 'www.substrakt.com'],
      auth_token: 'secrettoken'
    }
    post '/certificate_request', invalid_params
    assert last_response.unprocessable?
  end
end
