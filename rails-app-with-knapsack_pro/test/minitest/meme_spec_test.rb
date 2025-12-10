require 'test_helper'

class MemeTest < ActiveSupport::TestCase
  before do
    @meme = Meme.new
  end

  # test inside of describe won't be run when rspec is loaded, due to conflict:
  # https://stackoverflow.com/questions/23683009/minitest-not-picking-up-describe-blocks
  # To fix it we need to ensure rspec is not loaded when running minitest.
  # See if statement for KNAPSACK_PRO_RSPEC_DISABLED in Gemfile.
  describe "when asked about cheeseburgers" do
    it "must respond positively" do
      _(@meme.i_can_has_cheezburger?).must_equal "OHAI!"
    end
  end

  describe "when asked about blending possibilities" do
    context 'example context in describe' do
      it "won't say no" do
        _(@meme.will_it_blend?).wont_match /^no/i
      end
    end
  end

  context 'example context' do
    it "won't say no" do
      _(@meme.will_it_blend?).wont_match /^no/i
    end
  end

  it "outside of describe and context" do
    _(@meme.will_it_blend?).wont_match /^no/i
  end
end
