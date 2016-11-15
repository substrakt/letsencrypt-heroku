require_relative 'test_helper'

class CloudflareChallengeTest < MiniTest::Test

  def setup
    ENV['CLOUDFLARE_API_KEY'] = 'testtoken'
    ENV['CLOUDFLARE_EMAIL']   = 'max@substrakt.com'
    ENV['CONTACT_EMAIL']      = 'max@substrakt.com'
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

  def test_set_zone
    a = CloudflareChallenge.new(zone: 'substrakt.com')
    assert_equal 'substrakt.com', a.zone
  end

  def test_set_domains
    a = CloudflareChallenge.new(zone: 'substrakt.com', domains: ['www.substrakt.com', 'substrakt.com'])
    assert_equal ['www.substrakt.com', 'substrakt.com'], a.domains
  end

  def test_add_challenge_records_to_cloudflare
    VCR.use_cassette('acme-new-authz') do
      a = CloudflareChallenge.new(zone: 'substrakt.com',
                                  domains: ['www.substrakt.com', 'substrakt.com'],
                                  client: AcmeClientRegistration.new(debug: true).client)
      assert_equal ['www.substrakt.com', 'substrakt.com'], a.create_challenge_records
    end
  end

end
