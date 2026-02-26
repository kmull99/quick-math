# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'ruby2d'
require 'rubocop'
require './lib/question'
require './lib/text_display'
require './lib/toggle_text_button'

@submit_button = nil

@operators = []
@num_questions = 20
@time_limit = 120 # seconds

@questions = []
@question_display = nil
@wrong_answers = []
@score = 0

@input_display = nil

@start_time = nil

def end_quiz
  time = Time.now
  puts "Score: #{@score}/#{@num_questions}"
  puts "Time: #{(time - @start_time).to_i} seconds"

  if @score == @num_questions
    puts 'Perfect score!'
  else
    puts 'Questions to review:'
    @wrong_answers.each do |i|
      puts "    #{@questions[i].compose(answer: true)}"
    end
  end

  puts "\nPlay again? (y/n)"
  if %w[y Y].include?($stdin.gets.chomp)
    @questions.clear
    @wrong_answers.clear
    @score = 0
    @input_display.text = ('')
    gen_question
    @start_time = Time.now
  else
    quit
  end
end

def gen_question
  op = @operators.sample

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

  @questions << Question.new(x, y, op)

  @question_display[:op1].text = (@questions[-1].x)
  @question_display[:op2].text = (@questions[-1].y)
  @question_display[:operator].text = (@questions[-1].operation)
end

def make_buttons
  @submit_button = ToggleTextButton.new(
    text: 'Submit',
    coords: { x: 85, y: 175 },
    size: { width: 150, height: 50 }
  )
end

def make_display
  @question_display = {
    op1: TextDisplay.new(
      coords: { x: 135, y: 1 },
      size: { width: 50, height: 50 },
      background: false,
      orientation: :right
    ),
    op2: TextDisplay.new(
      coords: { x: 135, y: 50 },
      size: { width: 50, height: 50 },
      background: false,
      orientation: :right
    ),
    operator: TextDisplay.new(
      coords: { x: 90, y: 50 },
      background: false,
      size: { width: 50, height: 50 }
    ),
    equal_bar: Rectangle.new(
      x: 95, y: 90,
      width: 100, height: 5,
      color: 'black'
    )
  }

  @input_display = TextDisplay.new(
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

  @operators = ARGV[0] ? ARGV[0].chars.map(&:to_sym) : %i[+ -]

  make_buttons
  make_display
  gen_question

  on :key_down do |event|
    case event.key
    when 'escape'
      quit
    when 'return'
      next if @input_display.text.empty?

      @questions[-1].answer(@input_display.text)
      if @questions[-1].grade
        @score += 1
      else
        @wrong_answers << @questions.size - 1
      end

      if @questions.size == @num_questions
        end_quiz
      else
        @input_display.text = ('')
        gen_question
      end
    when 'backspace'
      tmp = @input_display.text
      next if tmp.empty?

      @input_display.text = (tmp[0..-2])
    when /[[:digit:]]/
      # Numpad keys print 'keypad #'
      # key[-1] accounts for both numpad & numrow
      @input_display.text = ("#{@input_display.text}#{event.key[-1]}")
    end
  end

  on :mouse_down do |event|
    if @submit_button.mouse_over?(event.x, event.y)
      @questions[-1].answer(@input_display.text)
      if @questions[-1].grade
        @score += 1
      else
        @wrong_answers << @questions.size - 1
      end

      if @questions.size == @num_questions
        end_quiz
      else
        @input_display.text = ('')
        gen_question
      end
    end
  end

  @start_time = Time.now

  if @time_limit
    tick = 0
    update do
      if (tick % 60).zero? && ((Time.now - @start_time).to_i > @time_limit)
        puts "Time limit exceeded.\n#{@num_questions - @questions.size + 1} questions unanswered.\n"
        end_quiz
      end
    end
  end

  show
end

main
