workers 2
threads_count = 5
threads threads_count, threads_count

rackup      DefaultRackup
port        ENV['PORT']     || 3000
environment ENV['RACK_ENV'] || 'development'
