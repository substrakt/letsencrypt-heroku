require 'sinatra'
require 'dotenv'
Dotenv.load

require_relative 'workers/worker'

get '/domain/:domain' do
  authenticate!
  token = SecureRandom.hex
  Worker.perform_async(params[:domain], params[:subdomains], params[:debug], params[:app_name], token)
  content_type :json

  { status_path: "#{request.env['rack.url_scheme']}://#{request.env['HTTP_HOST']}/certificate_generation/#{token}" }.to_json
end

get '/certificate_generation/:token' do
  authenticate!
  content_type :json
  $redis = Redis.new(url: ENV['REDIS_URL'])
  {
    token: params[:token],
    status: $redis.get("#{params[:token]}_status"),
    error: $redis.get("#{params[:token]}_error"),
    domain: $redis.get("#{params[:token]}_domain"),
    subdomains: $redis.get("#{params[:token]}_subdomains").split(','),
    message: $redis.get("#{params[:token]}_message")
  }.to_json
end

private

def authenticate!
  unless (params[:auth_token] == ENV['AUTH_TOKEN'])
    halt 403, 'Not authenticated'
  end

end
