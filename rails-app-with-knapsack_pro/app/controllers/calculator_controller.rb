class CalculatorController < ApplicationController
  def index
    @result = nil
  end

  def create
    calculator = Calculator.new
    @result = calculator.add(x, y)
    render 'index'
  end

  private

  def x
    @x = strong_params[:x].to_i
  end

  def y
    @y = strong_params[:y].to_i
  end

  def strong_params
    params.require(:calculator).permit(:x, :y)
  end
end
