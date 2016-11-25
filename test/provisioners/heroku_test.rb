require_relative '../test_helper'

class Provisioner::HerokuTest < MiniTest::Test

  def setup
    ENV['HEROKU_OAUTH_KEY'] = '67705361-152c-4761-96aa-ec904d6cd071'
    ENV['ENVIRONMENT'] = 'test'
  end

  def teardown
    $redis.flushdb
  end

  def test_creating_a_new_heroku_provisioner_should_return_false_if_using_free_dynos
    VCR.use_cassette('new-cert-provisioner-heroku') do
      a = CertificateGenerator.new(challenge: CloudflareChallenge.new(zone: 'substrakt.com',
                                                                      domains: ['www.substrakt.com', 'substrakt.com'],
                                                                      client: AcmeClientRegistration.new(debug: true).client))
      b = Provisioner::Heroku.new(app_name: 'ssl-test-maxwoolf', certificate: a.certificate)
      assert_equal false, b.provision!
    end
  end

  def test_creating_a_new_heroku_provisioner_should_return_true_if_successful
    VCR.use_cassette('new-cert-provisioner-heroku-success') do
      a = CertificateGenerator.new(challenge: CloudflareChallenge.new(zone: 'substrakt.com',
                                                                      domains: ['www.substrakt.com', 'substrakt.com'],
                                                                      client: AcmeClientRegistration.new(debug: true).client))
      b = Provisioner::Heroku.new(app_name: 'ssl-test-maxwoolf', certificate: a.certificate)
      assert_equal true, b.provision!
    end
  end

end
