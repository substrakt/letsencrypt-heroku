require_relative 'test_helper'

class LoggerTest < MiniTest::Test

  def setup
    ENV['ENVIRONMENT'] = 'test'
  end

  def teardown
    $redis.flushdb
  end

  def test_log_a_message_to_console
    assert_equal "----> This is a test message", Logger.log('This is a test message')
  end

  def test_log_with_request
    VCR.use_cassette('new-certificate-debug') do
      a = CertificateGenerator.new(challenge: CloudflareChallenge.new(zone: 'substrakt.com',
                                                                      domains: ['www.substrakt.com', 'substrakt.com'],
                                                                      client: AcmeClientRegistration.new(debug: true).client))
      assert_equal "[Zone: substrakt.com - Domains: www.substrakt.com, substrakt.com] ----> This is a test message", Logger.log('This is a test message', generator: a)
    end

  end

end
