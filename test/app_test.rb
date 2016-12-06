require_relative 'test_helper'

class AppTest < MiniTest::Test

  include Rack::Test::Methods

  def app
    Sinatra::Application
  end

  def setup
    ENV['AUTH_TOKEN'] = 'secrettoken'
  end

  def teardown
    $redis.flushdb
  end

  def test_certificate_request_post
    post '/certificate_request', { auth_token: 'secrettoken' }.to_json
    assert last_response.unprocessable?
  end

  def test_certificate_request_with_correct_params
    valid_params = {
      domains: ['substrakt.com', 'www.substrakt.com'],
      heroku_app_name: ['substrakt-live'],
      zone: ['substrakt.com'],
      auth_token: 'secrettoken'
    }
    post '/certificate_request', valid_params.to_json
    assert_equal 'application/json', last_response.content_type
    assert_equal 'queued', JSON.parse(last_response.body)["status"]
    assert_match /\w{32}/, JSON.parse(last_response.body)["uuid"]
    assert last_response.ok?
  end

  def test_certificate_missing_domain_list
    invalid_params = {
      heroku_app_name: ['substrakt-live'],
      auth_token: 'secrettoken'
    }
    post '/certificate_request', invalid_params.to_json
    assert last_response.unprocessable?
  end

  def test_certificate_missing_heroku_app_name
    invalid_params = {
      domains: ['substrakt.com', 'www.substrakt.com'],
      auth_token: 'secrettoken'
    }
    post '/certificate_request', invalid_params.to_json
    assert last_response.unprocessable?
  end

  def test_get_status_of_certificate_request_that_does_not_exist
    params = {
      auth_token: 'secrettoken'
    }
    get '/certificate_request/token1234', params
    assert_equal "token1234 not a valid token", JSON.parse(last_response.body)["status"]
    assert_equal 'application/json', last_response.content_type
    assert last_response.not_found?
  end

  def test_get_status_of_certificate_request_that_does_exist
    $redis.set('status_token1234', 'pending')

    params = {
      auth_token: 'secrettoken'
    }

    get '/certificate_request/token1234', params
    assert_equal 'application/json', last_response.content_type
    assert_equal 200, last_response.status
  end
end
