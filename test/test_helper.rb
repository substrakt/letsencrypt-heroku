ENV['RACK_ENV'] = 'test'
require 'minitest/autorun'
require 'rack/test'

require_relative '../app'
require_relative '../lib/acme_client_registration'
require_relative '../lib/cloudflare_challenge'
