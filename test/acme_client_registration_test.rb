require_relative 'test_helper'

class AcmeClientRegistrationTest < MiniTest::Test

  def teardown
    $redis.flushall
  end

  def test_create_an_instance
    a = AcmeClientRegistrationTest.new
    assert_equal AcmeClientRegistrationTest, a.class
  end

end
