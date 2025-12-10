require 'test_helper'

class FooTest < Test::Unit::TestCase
  class << self
    def startup
      puts 'STARTUP --------'
    end

    def shutdown
      puts 'SHUTDOWN --------'
    end
  end

  def setup
    puts 'SETUP --------'
  end

  def teardown
    puts 'TEARDOWN --------'
  end

  test "the truth" do
    assert true
  end

  test "yet another truth" do
    assert true
  end
end
