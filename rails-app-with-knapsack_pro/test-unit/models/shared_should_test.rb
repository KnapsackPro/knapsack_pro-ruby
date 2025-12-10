require 'test_helper'

class Book
  attr_accessor :rentable, :purchasable

  def available_for_checkout?
    true
  end
end

class SharedShouldTest < Test::Unit::TestCase
  test "shared should 1" do
    assert true
  end

  test "shared should 2" do
    assert true
  end

  context "Book" do
    context "with an in-stock book" do
      setup { @book = Book.new }

      ### Define a shared should
      share_should "be available for checkout" do
        assert @book.available_for_checkout?
      end

      context "with a rentable book - context" do
        setup { @book.rentable = true }

        ### Use the "be available for checkout" share_should
        use_should "be available for checkout"
      end

      context "with a purchasable book - context" do
        setup { @book.purchasable = true }

        ### Use the "be available for checkout" share_should in this context too
        use_should "be available for checkout"
      end

      ### ...or DRY it with chaining
      setup("with a rentable book") do
        @book.rentable = true
      end.use_should("be available for checkout")

      setup("with a purchasable book") do
        @book.purchasable = true
      end.use_should("be available for checkout")
    end
  end
end
