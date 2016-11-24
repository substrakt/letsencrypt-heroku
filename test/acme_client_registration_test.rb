require_relative 'test_helper'

class AcmeClientRegistrationTest < MiniTest::Test

  def setup
    ENV['CONTACT_EMAIL'] = 'test@example.com'
  end

  def teardown
    $redis.flushdb
  end

  def test_create_an_instance
    VCR.use_cassette('acme-new-reg') do
      a = AcmeClientRegistration.new
      assert_equal AcmeClientRegistration, a.class
    end
  end

  def test_use_the_staging_endpoint
    VCR.use_cassette('acme-new-reg-debug') do
      a = AcmeClientRegistration.new(debug: true)
      assert_equal 'https://acme-staging.api.letsencrypt.org/', a.endpoint
    end
  end

  def test_use_the_live_endpoint
    VCR.use_cassette('acme-new-reg') do
      a = AcmeClientRegistration.new(debug: false)
      assert_equal 'https://acme-v01.api.letsencrypt.org/', a.endpoint
    end
  end

  def test_use_the_live_endpoint_by_default
    VCR.use_cassette('acme-new-reg') do
      a = AcmeClientRegistration.new
      assert_equal 'https://acme-v01.api.letsencrypt.org/', a.endpoint
    end
  end

  def test_assign_an_acme_client_with_live_endpoint
    VCR.use_cassette('acme-new-reg') do
      a = AcmeClientRegistration.new
      assert_equal Acme::Client, a.client.class
      assert_equal 'https://acme-v01.api.letsencrypt.org/', a.client.connection.url_prefix.to_s
    end
  end

  def test_assign_an_acme_client_with_test_endpoint
    VCR.use_cassette('acme-new-reg-debug') do
      a = AcmeClientRegistration.new(debug: true)
      assert_equal Acme::Client, a.client.class
      assert_equal 'https://acme-staging.api.letsencrypt.org/', a.client.connection.url_prefix.to_s
    end
  end

  def test_creating_without_CONTACT_EMAIL_set_should_raise_an_exception
    VCR.use_cassette('acme-new-reg') do
      ENV['CONTACT_EMAIL'] = nil
      assert_raises AcmeClientRegistration::NoEmailError do
        AcmeClientRegistration.new
      end
    end
  end

  def test_client_should_be_registered_and_agreed_to
    VCR.use_cassette('acme-new-reg') do
      a = AcmeClientRegistration.new
      assert_equal true, a.client.nonces.any?
    end
  end

end
