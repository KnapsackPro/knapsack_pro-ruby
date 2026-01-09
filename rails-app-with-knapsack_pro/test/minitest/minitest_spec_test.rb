require "test_helper"

class MinitestSpecTest < ActiveSupport::TestCase
  describe "oneword" do
    it "works" do
      _(1).must_equal 1
    end
  end

  describe "two words" do
    it "really works" do
      _(1).must_equal 1
    end
  end

  context "with nested" do
    describe "described in context" do
      it "works" do
        _(1).must_equal 1
      end
    end
  end

  describe "with nested" do
    context "context in describe" do
      it "works" do
        _(1).must_equal 1
      end
    end
  end

  it "top level it" do
    _(1).must_equal 1
  end
end
