require 'sinatra'
require 'dotenv'
require 'sidekiq'
Dotenv.load

require_relative 'workers/cloudflare_challenge_worker'

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
    status 200
    token = SecureRandom.hex
    $redis.setex("status_#{token}", 3600, "queued")
    CloudflareChallengeWorker.perform_async(@request_payload["zone"], @request_payload["domains"], token, @request_payload["heroku_app_name"], false, { email: @request_payload['cloudflare_email'], api_key: @request_payload['cloudflare_api_key'] }, heroku: { oauth_key: @request_payload['heroku_oauth_token']})
    { status: 'queued', uuid: token, url: "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/certificate_request/#{token}?auth_token=#{ENV['AUTH_TOKEN']}" }.to_json
  else
    status 422
  end
end

get '/certificate_request/:token' do
  content_type :json
  authenticate!
  if $redis.exists("status_#{params["token"]}")
    status 200
    return { status: $redis.get("status_#{params["token"]}"), message: $redis.get("latest_#{params["token"]}")}.to_json
  end
  status 404
  { status: "#{params["token"]} not a valid token" }.to_json
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
