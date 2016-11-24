require_relative 'test_helper'

class CertificateGeneratorTest < MiniTest::Test

  def setup
    ENV['CLOUDFLARE_API_KEY'] = '547348956734789576'
    ENV['CLOUDFLARE_EMAIL']   = 'max@substrakt.com'
    ENV['CONTACT_EMAIL']      = 'max@substrakt.com'
  end

  def teardown
    $redis.flushdb
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
