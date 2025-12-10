require 'test_helper'

# This test never run because it will be override by test/minitest_duplicated/meme_unit_test.rb
class TestMeme < Minitest::Test
  def setup
    @meme = Meme.new
  end

  def test_that_kitty_can_eat
    puts 'Meme first test with minitest syntax'
    assert_equal "OHAI!", @meme.i_can_has_cheezburger?
  end

  def test_that_it_will_not_blend
    refute_match /^no/i, @meme.will_it_blend?
  end

  def test_that_will_be_skipped
    skip "test this later"
    # ensure this will be skipped and 5s delay won't happen
    sleep 5
  end
end
