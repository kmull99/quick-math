# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'ruby2d'
require 'rubocop'
require './lib/question'
require './lib/toggle_text_button'

@submit_button = nil

@questions = []
@question_display = nil
@wrong_answers = []
@score = 0

@input_display = nil

@start_time = nil

def end_quiz
  time = Time.now
  puts "Score: #{@score}/#{@questions.size}"
  puts "Time: #{(time - @start_time).to_i} seconds"

  if @wrong_answers.empty?
    puts 'Perfect score!'
  else
    puts 'Questions to review:'
    @wrong_answers.each do |i|
      puts "    #{@questions[i].compose}"
    end
  end

  quit
end

def gen_question
  op = rand(2).zero? ? :+ : :-
  x = rand(21)
  y = rand(21)

  # Ensure answer is not negative. This is only second grade math.
  if op == :- && x < y
    temp = x
    x = y
    y = temp
  end

  @questions << Question.new(x, y, op)

  @question_display.set_text(@questions[-1].compose)
end

def make_buttons
  @submit_button = ToggleTextButton.new(
    text: 'Submit',
    coords: { x: 85, y: 175 },
    size: { width: 150, height: 50 }
  )
end

def make_display
  @question_display = ToggleTextButton.new(
    coords: { x: 60, y: 25 },
    size: { width: 200, height: 50 }
  )

  @input_display = ToggleTextButton.new(
    coords: { x: 60, y: 100 },
    size: { width: 200, height: 50 }
  )
end

def quit
  close
end

def main
  set title: 'Type Math',
      background: 'gray',
      width: 320,
      height: 250,
      resizable: false

  make_buttons
  make_display
  gen_question

  on :key_down do |event|
    case event.key
    when 'escape'
      quit
    when 'return'
      next if @input_display.get_text.empty?

      @questions[-1].answer(@input_display.get_text)
      if @questions[-1].grade
        @score += 1
      else
        @wrong_answers << @questions.size - 1
      end

      if @questions.size == 20
        end_quiz
      else
        @input_display.set_text('')
        gen_question
      end
    when 'backspace'
      tmp = @input_display.get_text
      next if tmp.empty?

      @input_display.set_text(tmp[0..-2])
    when /[[:digit:]]/
      @input_display.set_text("#{@input_display.get_text}#{event.key}")
    end
  end

  on :mouse_down do |event|
    if @submit_button.mouse_over?(event.x, event.y)
      @questions[-1].answer(@input_display.get_text)
      if @questions[-1].grade
        @score += 1
      else
        @wrong_answers << @questions.size - 1
      end

      if @questions.size == 20
        end_quiz
      else
        gen_question
      end
    end
  end

  @start_time = Time.now

  show
end

main
