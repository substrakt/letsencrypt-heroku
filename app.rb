require 'sinatra'
require 'dotenv'
require 'sidekiq'
Dotenv.load

require_relative 'workers/cloudflare_challenge_worker'
require_relative 'lib/preflight_check'

$redis = Redis.new(url: ENV['REDIS_URL'])

before do
  request.body.rewind
  if request.body.size > 0
    @request_payload = JSON.parse(request.body.read)
  end
end

post '/certificate_request' do
  content_type :json
  authenticate!
  if params_valid?
    perform_preflight_check unless ENV['ENVIRONMENT'] == 'test'
    status 200
    token = SecureRandom.hex
    CloudflareChallengeWorker.perform_async(@request_payload["zone"], @request_payload["domains"], token, @request_payload["heroku_app_name"], false)
    { status: 'queued', uuid: token }.to_json
  else
    status 422
  end
end

get '/certificate_request/:token' do
  content_type :json
  authenticate!
  if $redis.exists("status_#{params["token"]}")
    return status 200
  end
  status 404
  { status: 'token1234 not a valid token' }.to_json
end

private

def params_valid?
  @request_payload["domains"].present? && @request_payload["heroku_app_name"].present? && @request_payload["zone"].present?
end

private

def authenticate!
  unless (params["auth_token"] == ENV['AUTH_TOKEN']) || (@request_payload["auth_token"] == ENV['AUTH_TOKEN'])
    halt 403
  end
end

def perform_preflight_check
  check = PreflightCheck.new(heroku_token: ENV['HEROKU_OAUTH_KEY'], cloudflare_token: ENV['CLOUDFLARE_API_KEY'], cloudflare_email: ENV['CLOUDFLARE_EMAIL'])

  if check.check_cloudflare == false || check.check_heroku == false
    halt 422, "Could not connect to Heroku or Cloudflare."
  end
end
