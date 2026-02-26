# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'ruby2d'
require 'rubocop'
require './lib/question'
require './lib/text_display'
require './lib/toggle_text_button'

@choice_buttons = []
@selected_button = nil
@submit_button = nil

@operators = []
@num_questions = 20
@time_limit = 120 # seconds

@questions = []
@question_display = nil
@wrong_answers = []
@score = 0

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
    @choice_buttons[i].text = (choices[i])
  end

  @question_display[:op1].text = (@questions[-1].x)
  @question_display[:op2].text = (@questions[-1].y)
  @question_display[:operator].text = (@questions[-1].operation)
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
  @question_display = {
    op1: TextDisplay.new(
      coords: { x: 135, y: 15 },
      size: { width: 50, height: 50 },
      background: false,
      orientation: :right
    ),
    op2: TextDisplay.new(
      coords: { x: 135, y: 65 },
      size: { width: 50, height: 50 },
      background: false,
      orientation: :right
    ),
    operator: TextDisplay.new(
      coords: { x: 90, y: 65 },
      background: false,
      size: { width: 50, height: 50 }
    ),
    equal_bar: Rectangle.new(
      x: 95, y: 110,
      width: 100, height: 5,
      color: 'black'
    )
  }
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

  @operators = ARGV[0] ? ARGV[0].chars.map(&:to_sym) : %i[+ -]
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

      if @questions.size == @num_questions
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

      @questions[-1].answer(@selected_button.text)
      if @questions[-1].grade
        @score += 1
      else
        @wrong_answers << @questions.size - 1
      end

      @selected_button.toggle
      @selected_button = nil

      if @questions.size == @num_questions
        end_quiz
      else
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
