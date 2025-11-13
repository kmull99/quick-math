# frozen_string_literal: true

require 'rubocop'

class Question
  @x = nil
  @y = nil
  @operation = nil
  @answer = nil

  def initialize(x, y, operation)
    @x = x
    @y = y
    @operation = operation
  end

  def pretty_print
    print compose
  end

  def answer(answer)
    @answer = answer
  end

  def grade
    # Ensure answer is an integer
    return false unless @answer && @answer.to_i.to_s == @answer

    case @operation
    when :+
      @x.to_i + @y.to_i == @answer.to_i
    when :-
      @x.to_i - @y.to_i == @answer.to_i
    when :*
      @x.to_i * @y.to_i == @answer.to_i
    when :/
      @x.to_i / @y.to_i == @answer.to_i
    when :%
      @x.to_i % @y.to_i == @answer.to_i
    end
  end

  def compose
    "#{@x} #{@operation} #{@y} = "
  end
end
