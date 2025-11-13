# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'rubocop'
require './lib/question'

score = 0
wrong = []
time = Time.now

20.times do
  question = Question.new(rand(20), rand(20), :+)

  puts "\n"
  question.pretty_print
  input = gets.chomp.delete_prefix('0')
  question.answer(input)

  print "\e[1A"  # move up one line
  print "\e[K"   # clear the whole line
  question.pretty_print
  print input
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
  q.pretty_print
  puts
end
