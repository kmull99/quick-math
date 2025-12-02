# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'ruby2d'
require 'rubocop'
require './lib/question'
require './lib/toggle_text_button'

@choice_buttons = []
@selected_button = nil
@submit_button = nil

@operators = []
@questions = []
@question_display = nil
@wrong_answers = []
@score = 0

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
      puts "    #{@questions[i].compose(answer: true)}"
    end
  end

  puts "\nPlay again? (y/n)"
  if %w[y Y].include?(gets.chomp)
    @questions.clear
    @wrong_answers.clear
    @score = 0
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

  choices = [@questions[-1].correct_answer]
  choices << off_by_few(choices[0])
  choices << off_by_ten(choices[0])
  choices << wrong_operation(x, y, op)
  choices.shuffle!

  (0..3).each do |i|
    @choice_buttons[i].set_text(choices[i])
  end

  @question_display.set_text(@questions[-1].compose)
end

def make_buttons
  (0..1).each do |i|
    (0..1).each do |n|
      @choice_buttons << ToggleTextButton.new(
        coords: { x: 50 + n * 120, y: 140 + i * 120 },
        size: { width: 100, height: 100 }
      )
    end
  end

  @submit_button = ToggleTextButton.new(
    text: 'Submit',
    coords: { x: 85, y: 400 },
    size: { width: 150, height: 50 }
  )
end

def make_display
  @question_display = ToggleTextButton.new(
    coords: { x: 60, y: 25 },
    size: { width: 200, height: 50 }
  )
end

def make_sounds
  @sounds[:correct] = Sound.new('assets/sounds/minecraft-xp.mp3')
  @sounds[:streak] = Sound.new('assets/sounds/minecraft-level-up.mp3')
  @sounds[:wrong] = Sound.new('assets/sounds/minecraft-hurt.mp3')
  @sounds[:button] = Sound.new('assets/sounds/minecraft-click.mp3')
  @sounds[:lose] = Sound.new('assets/sounds/villager-death.mp3')
end

def off_by_few(num)
  rand(2).zero? ? num + 1 + rand(5) : num - 1 - rand(5)
end

def off_by_ten(num)
  num < 10 || rand(2).zero? ? num + 10 : num - 10
end

def wrong_operation(x, y, op)
  case op
  when :+
    x - y
  when :-
    x + y
  when :*
    if rand(2).zero? || x.zero? || y.zero?
      x + y
    else
      x > y ? x / y : y / x
    end
  when :/
    if rand(2).zero?
      x - y
    else
      x * y
    end
  when :%
    x / y
  end
end

def quit
  close
end

def main
  set title: 'Choice Math',
      background: 'gray',
      width: 320,
      height: 480,
      resizable: false

  @operators = %i[+ - * / %]
  make_buttons
  make_display
  gen_question

  on :key_down do |event|
    case event.key
    when 'escape'
      quit
    when 'return'
      next unless @selected_button

      @questions[-1].answer(@selected_button.get_text)
      if @questions[-1].grade
        @score += 1
      else
        @wrong_answers << @questions.size - 1
      end

      @selected_button.toggle
      @selected_button = nil

      if @questions.size == 20
        end_quiz
      else
        gen_question
      end
    end
  end

  on :mouse_down do |event|
    @choice_buttons.each do |button|
      next unless button.mouse_over?(event.x, event.y)
      next if @selected_button == button

      @selected_button&.toggle
      @selected_button = button
      @selected_button.toggle
    end

    if @submit_button.mouse_over?(event.x, event.y)
      next unless @selected_button

      @questions[-1].answer(@selected_button.get_text)
      if @questions[-1].grade
        @score += 1
      else
        @wrong_answers << @questions.size - 1
      end

      @selected_button.toggle
      @selected_button = nil

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
