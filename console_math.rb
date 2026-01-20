# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'rubocop'
require './lib/question'

operators = ARGV[0] ? ARGV[0].chars.map(&:to_sym) : %i[+ -]

loop do
  score = 0
  wrong = []
  time = Time.now

  20.times do
    op = operators.sample

    case op
    when :+
      x = rand(21)
      y = rand(21)
    when :-
      x = rand(21)
      y = rand(21)
      # Ensure answer is non-negative
      if x < y
        tmp = x
        x = y
        y = tmp
      end
    when :*
      x = rand(11)
      y = rand(11)
    when :/
      # Ensure there is no remainder
      y = rand(1..10)
      x = y * rand(11)
    when :%
      x = rand(11..100)
      y = rand(1..10)
    end

    question = Question.new(x, y, op)

    puts "\n"
    question.pretty_print
    print '  '
    input = gets.chomp
    question.answer(input)

    3.times do
      print "\e[1A"  # move up one line
      print "\e[K"   # clear the whole line
    end
    question.pretty_print
    print input.rjust(4)
    puts "\n"
    if question.grade
      score += 1
      # puts "\t Correct"
    else
      wrong << question
      # puts "\t Wrong"
    end
  end

  puts "\nScore: #{score}/20"
  puts "Time: #{(Time.now - time).to_i} seconds"

  puts 'Questions to review:'
  wrong.each do |q|
    puts "    #{q.compose(answer: true)}"
    puts
  end

  puts "\nPlay again? (y/n)"
  exit unless %w[y Y].include?(gets.chomp)
end
