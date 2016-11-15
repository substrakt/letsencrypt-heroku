require_relative 'test_helper'

class CertificateGeneratorTest < MiniTest::Test

  def teardown
    $redis.flushall
  end

  def test_generate_certificate
    VCR.use_cassette('new-certificate-debug') do
      a = CertificateGenerator.new(challenge: CloudflareChallenge.new(zone: 'substrakt.com',
                                                                      domains: ['www.substrakt.com', 'substrakt.com'],
                                                                      client: AcmeClientRegistration.new(debug: true).client))
      assert_equal Acme::Client::Certificate, a.certificate.class
    end
  end

end
