require_relative 'test_helper'

class PreflightCheckTest < MiniTest::Test

  def setup
    ENV['ENVIRONMENT'] = 'test'
  end

  def teardown
    $redis.flushdb
  end

  def test_check_heroku_should_return_true_if_the_oauth_token_is_valid
    VCR.use_cassette('check-heroku-authentication-succeed') do
      a = PreflightCheck.new(heroku_token: '3c3b9d66-015a-4c91-bda2-14c79c88fb15')
      assert_equal true, a.check_heroku
    end
  end

  def test_check_heroku_should_return_false_if_the_oauth_token_is_not_valid
    VCR.use_cassette('check-heroku-authentication-failure') do
      a = PreflightCheck.new(heroku_token: 'this-is-not-a-real-token')
      assert_equal false, a.check_heroku
    end
  end

  def test_check_cloudflare_should_return_true_if_the_token_is_valid
    VCR.use_cassette('check-cloudflare-authentiation-success') do
      # These tokens have since been revoked from the cloudflare account.
      a = PreflightCheck.new(cloudflare_token: '856a0658ade46696ec3e165827d728382f989', cloudflare_email: 'notarealemail@example.com')
      assert_equal true, a.check_cloudflare
    end
  end

  def test_check_cloudflare_should_return_false_if_the_token_is_invalid
    VCR.use_cassette('check-cloudflare-authentiation-failure') do
      a = PreflightCheck.new(cloudflare_token: 'this-is-not-a-real-token', cloudflare_email: 'notarealemail@example.com')
      assert_equal false, a.check_cloudflare
    end
  end

end
