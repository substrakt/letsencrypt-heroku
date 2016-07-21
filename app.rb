require 'sinatra'
require 'dotenv'
Dotenv.load


require_relative 'workers/worker'

get '/domain/:domain' do
  authenticate!
  Worker.perform_async(params[:domain], params[:subdomains], params[:debug], params[:app_name])
  'Performing SSL tasks in the background. This can take a few minutes (atleast 1min per subdomain). Check the logs for more info.'
end

private

def authenticate!
  unless (params[:auth_token] == ENV['AUTH_TOKEN'])
    halt 403, 'Not authenticated'
  end

end
