require_relative 'test_helper'

class LoggerTest < MiniTest::Test

  def setup
    ENV['ENVIRONMENT'] = 'test'
    ENV['CLOUDFLARE_API_KEY'] = 'fjsdjfghsdjfhgsd'
    ENV['CLOUDFLARE_EMAIL'] = 'max@substrakt.com'
  end

  def teardown
    $redis.flushdb
  end

  def test_log_a_message_to_console
    assert_equal "----> This is a test message", Logger.log('This is a test message')
  end

  def test_log_with_generator
    VCR.use_cassette('new-certificate-debug') do
      a = CertificateGenerator.new(challenge: CloudflareChallenge.new(zone: 'substrakt.com',
                                                                      domains: ['www.substrakt.com', 'substrakt.com'],
                                                                      api_key: 'fsdfdsf',
                                                                      email: 'adam@example.com',
                                                                      client: AcmeClientRegistration.new(debug: true).client))
      assert_equal "[Zone: substrakt.com - Domains: www.substrakt.com, substrakt.com] ----> This is a test message", Logger.log('This is a test message', generator: a)
    end
  end

  def test_a_log_with_generator_should_also_write_to_redis
    VCR.use_cassette('new-certificate-debug') do
      a = CertificateGenerator.new(challenge: CloudflareChallenge.new(zone: 'substrakt.com',
                                                                      token: 'testingtesting',
                                                                      api_key: 'fsdfdsf',
                                                                      email: 'adam@example.com',
                                                                      domains: ['www.substrakt.com', 'substrakt.com'],
                                                                      client: AcmeClientRegistration.new(debug: true).client))
      Logger.log('Test message', generator: a)
      assert_equal "Test message", $redis.get("latest_testingtesting")
    end
  end

end
