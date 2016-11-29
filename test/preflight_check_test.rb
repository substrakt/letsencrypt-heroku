require_relative 'test_helper'

class PreflightCheckTest < MiniTest::Test

  def setup
    ENV['ENVIRONMENT'] = 'test'
  end

  def teardown
    $redis.flushdb
  end

end
