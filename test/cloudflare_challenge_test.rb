require_relative 'test_helper'

class CloudflareChallengeTest < MiniTest::Test

  def setup
    ENV['CLOUDFLARE_API_KEY'] = 'abcdefhuifsdjkfs'
    ENV['CLOUDFLARE_EMAIL']   = 'test@example.com'
  end

  def teardown
    $redis.flushall
  end

  def test_create_an_instance
    a = CloudflareChallenge.new
    assert_equal CloudflareChallenge, a.class
  end

  def test_raise_an_exception_if_CLOUDFLARE_API_KEY_is_missing
    ENV['CLOUDFLARE_API_KEY'] = nil
    assert_raises CloudflareChallenge::NoCloudflareAPIKey do
      CloudflareChallenge.new
    end
  end

  def test_raise_an_exception_if_CLOUDFLARE_EMAIL_is_missing
    ENV['CLOUDFLARE_EMAIL'] = nil
    assert_raises CloudflareChallenge::NoCloudflareEmail do
      CloudflareChallenge.new
    end
  end

end
