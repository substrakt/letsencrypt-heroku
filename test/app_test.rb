require_relative 'test_helper'

class AppTest < MiniTest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def test_certificate_request_post
    post '/certificate_request'
    assert last_response.unprocessable?
  end

  def test_certificate_request_with_correct_params
    valid_params = {
      domains: ['substrakt.com', 'www.substrakt.com'],
      heroku_app_name: ['substrakt-live']
    }
    post '/certificate_request', valid_params
    assert last_response.ok?
  end

  def test_certificate_missing_domain_list
    invalid_params = {
      heroku_app_name: ['substrakt-live']
    }
    post '/certificate_request', invalid_params
    assert last_response.unprocessable?
  end

  def test_certificate_missing_heroku_app_name
    invalid_params = {
      domains: ['substrakt.com', 'www.substrakt.com']
    }
    post '/certificate_request', invalid_params
    assert last_response.unprocessable?
  end
end
