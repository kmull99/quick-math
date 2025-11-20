# frozen_string_literal: true

require 'rubocop'

class Question
  @x = nil
  @y = nil
  @operation = nil
  @answer = nil
  @correct_answer = nil

  def initialize(x, y, operation)
    @x = x.to_i
    @y = y.to_i
    @operation = operation
  end

  def correct_answer
    @correct_answer ||= case @operation
                        when :+
                          @x + @y
                        when :-
                          @x - @y
                        when :*
                          @x * @y
                        when :/
                          @x / @y
                        when :%
                          @x % @y
                        end
  end

  def pretty_print
    print compose
  end

  def answer(answer)
    @answer = answer.to_i
  end

  def grade
    @answer == correct_answer
  end

  def compose
    "#{@x} #{@operation} #{@y} = "
  end
end
