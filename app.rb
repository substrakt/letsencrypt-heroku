require 'sinatra'
require 'dotenv'
Dotenv.load

require_relative 'workers/worker'

get '/domain/:domain' do
  authenticate!
  token = SecureRandom.hex
  Worker.perform_async(params[:domain], params[:subdomains], params[:debug], params[:app_name], token)
  token
end

private

def authenticate!
  unless (params[:auth_token] == ENV['AUTH_TOKEN'])
    halt 403, 'Not authenticated'
  end

end
