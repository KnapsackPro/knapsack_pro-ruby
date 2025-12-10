require 'test_helper'

class MemeDirWithSpacesTest < ActiveSupport::TestCase
  before do
    @meme = Meme.new
  end

  #describe "when asked about cheeseburgers" do
  it "must respond positively - dir with spaces" do
    _(@meme.i_can_has_cheezburger?).must_equal "OHAI!"
  end

  #describe "when asked about blending possibilities" do
  it "won't say no - dir with spaces" do
    _(@meme.will_it_blend?).wont_match /^no/i
  end
end
