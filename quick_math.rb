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

@questions = []
@question_display = nil
@wrong_answers = []
@score = 0

@sounds = {}

@start = nil

def end_quiz
  time = Time.now
  puts "Score: #{@score}"
  puts "Time: #{(time - @start).to_i} seconds"

  return puts 'Perfect score!' if @wrong_answers.empty?

  puts 'Questions to review:'
  @wrong_answers.each do |i|
    puts "    #{@questions[i].compose}"
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

  choices = [op == :+ ? x + y : x - y]
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
  rv = op == :+ ? x - y : x + y

  rv.negative? ? rand(10) : rv
end

def quit
  close
end

def main
  set title: 'Quick Math',
      background: 'gray',
      width: 320,
      height: 480,
      resizable: false

  make_buttons
  make_display
  # make_sounds
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
      # @sounds[:button].play

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
      # @sounds[:button].play
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
      # @sounds[:button].play

      if @questions.size == 20
        end_quiz
      else
        gen_question
      end
    end
  end

  @start = Time.now

  show
end

main
