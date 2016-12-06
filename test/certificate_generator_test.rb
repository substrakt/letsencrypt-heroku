require_relative 'test_helper'

class CertificateGeneratorTest < MiniTest::Test

  def setup
    ENV['CONTACT_EMAIL']      = 'max@substrakt.com'
  end

  def teardown
    $redis.flushdb
  end

  def test_generate_certificate
    VCR.use_cassette('new-certificate-debug') do
      a = CertificateGenerator.new(challenge: CloudflareChallenge.new(zone: 'substrakt.com',
                                                                      domains: ['www.substrakt.com', 'substrakt.com'],
                                                                      api_key: 'fsdfdsf',
                                                                      email: 'adam@example.com',
                                                                      client: AcmeClientRegistration.new(debug: true).client))
      assert_equal Acme::Client::Certificate, a.certificate.class
    end
  end

end
