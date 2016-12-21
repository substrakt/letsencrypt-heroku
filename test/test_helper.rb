ENV['RACK_ENV'] = 'test'
ENV['ENVIRONMENT'] = 'test'
require 'minitest/autorun'
require 'rack/test'
require 'vcr'

require_relative '../app'
require_relative '../lib/acme_client_registration'
require_relative '../lib/cloudflare_challenge'
require_relative '../lib/challenge'
require_relative '../lib/certificate_generator'
require_relative '../lib/provisioners/heroku'
require_relative '../lib/logger'


VCR.configure do |config|
  config.cassette_library_dir = "test/fixtures/vcr_cassettes"
  config.hook_into :webmock
end
