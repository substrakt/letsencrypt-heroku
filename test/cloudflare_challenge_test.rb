require_relative 'test_helper'

class CloudflareChallengeTest < MiniTest::Test

  def setup
    ENV['CLOUDFLARE_API_KEY'] = '547348956734789576'
    ENV['CLOUDFLARE_EMAIL']   = 'max@substrakt.com'
    ENV['CONTACT_EMAIL']      = 'max@substrakt.com'
  end

  def teardown
    $redis.flushdb
  end

  def test_create_an_instance
    VCR.use_cassette('acme-new-authz') do
      a = CloudflareChallenge.new(zone: 'substrakt.com',
                                  domains: ['www.substrakt.com', 'substrakt.com'],
                                  client: AcmeClientRegistration.new(debug: true).client)
      assert_equal CloudflareChallenge, a.class
    end
  end

  def test_create_an_instance_with_custom_auth
    ENV['CLOUDFLARE_EMAIL']   = nil
    ENV['CLOUDFLARE_API_KEY'] = nil
    VCR.use_cassette('acme-new-authz') do
      a = CloudflareChallenge.new(zone: 'substrakt.com',
                                  domains: ['www.substrakt.com', 'substrakt.com'],
                                  api_key: 'fdhsufgdjshfgsd',
                                  email: 'max@substrakt.com',
                                  client: AcmeClientRegistration.new(debug: true).client)
      assert_equal 'max@substrakt.com', a.email
      assert_equal 'fdhsufgdjshfgsd', a.api_key
    end
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
    VCR.use_cassette('acme-new-authz') do
      a = CloudflareChallenge.new(zone: 'substrakt.com',
                                  domains: ['www.substrakt.com', 'substrakt.com'],
                                  client: AcmeClientRegistration.new(debug: true).client)
      assert_equal 'substrakt.com', a.zone
    end
  end

  def test_set_domains
    VCR.use_cassette('acme-new-authz') do
      a = CloudflareChallenge.new(zone: 'substrakt.com',
                                  domains: ['www.substrakt.com', 'substrakt.com'],
                                  client: AcmeClientRegistration.new(debug: true).client)
      assert_equal ['www.substrakt.com', 'substrakt.com'], a.domains
    end
  end

  def test_add_challenge_records_to_cloudflare
    VCR.use_cassette('acme-new-authz') do
      a = CloudflareChallenge.new(zone: 'substrakt.com',
                                  domains: ['www.substrakt.com', 'substrakt.com'],
                                  client: AcmeClientRegistration.new(debug: true).client)
      assert_equal ['www.substrakt.com', 'substrakt.com'], a.create_challenge_records
    end
  end

  def test_get_list_of_challenges
    VCR.use_cassette('acme-new-authz') do
      a = CloudflareChallenge.new(zone: 'substrakt.com',
                                  domains: ['www.substrakt.com', 'substrakt.com'],
                                  client: AcmeClientRegistration.new(debug: true).client)
      assert_equal Challenge, a.challenges.first.class
    end
  end

  def test_verification
    VCR.use_cassette('acme-challenge-debug') do
      a = CloudflareChallenge.new(zone: 'substrakt.com',
                                  domains: ['max123.substrakt.com', 'max345.substrakt.com'],
                                  client: AcmeClientRegistration.new(debug: true).client)
      assert_equal true, a.verify
    end
  end

end
