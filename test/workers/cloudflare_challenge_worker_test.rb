require_relative '../test_helper'
require 'sidekiq/testing'

class CloudflareChallengeWorkerTest < MiniTest::Test
  Sidekiq::Testing.inline!

  def test_success_callback_called
    VCR.use_cassette('new-cert-provisioner-heroku-success') do
      VCR.use_cassette('acme-new-actual-authz') do
        HTTParty.expects(:post).with('http://example.com/callback', body: { status: 'succeded', message: '' }).once
  zone, domains, token, app_name, debug = true, cloudflare = {}, heroku = {}, callback_url = nil
        CloudflareChallengeWorker.perform_async('substrakt.com', ['max123.substrakt.com', 'max345.substrakt.com'], 'fsdfdsf', 'substrakt.herokuapp.com', true, {}, {}, 'http://example.com/callback')
      end
    end
  end

  def test_failed_callback_called
    VCR.use_cassette('acme-v01-api') do
      HTTParty.expects(:post).with('http://example.com/callback', body: { status: 'failed', message: 'No or invalid host_key.' }).once
zone, domains, token, app_name, debug = true, cloudflare = {}, heroku = {}, callback_url = nil
      CloudflareChallengeWorker.perform_async('substrakt.com', ['max123.substrakt.com', 'max345.substrakt.com'], 'fsdfdsf', 'substrakt.herokuapp.com', true, {}, {}, 'http://example.com/callback')
    end
  end
end
