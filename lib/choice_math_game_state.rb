# frozen_string_literal: true

require 'rubocop'
require_relative 'game_state'

class ChoiceMathGameState < GameState
  # @choice_buttons
  # @selected_button
  # @submit_button

  # @question_display

  def initialize(game)
    puts 'Initializing Choice Math game state'

    make_buttons
    make_display

    super
  end

  def handle_key_event(event)
    case event.key
    when 'return'
      return unless @selected_button

      @game.questions[-1].answer(@selected_button.text)
      if @game.questions[-1].grade
        @game.score += 1
      else
        @game.wrong_answers << @game.questions.last
      end

      @selected_button.toggle
      @selected_button = nil

      if @game.questions.size == @game.num_questions
        end_quiz
      else
        gen_question
      end
    end
  end

  def handle_mouse_event(event)
    # Select answer
    @choice_buttons.each do |button|
      next unless button.mouse_over?(event.x, event.y)
      next if @selected_button == button

      @selected_button&.toggle
      @selected_button = button
      @selected_button.toggle
    end

    # Submit answer
    return unless @selected_button && @submit_button.mouse_over?(event.x, event.y)

    @game.questions[-1].answer(@selected_button.text)
    if @game.questions[-1].grade
      @game.score += 1
    else
      @game.wrong_answers << @game.questions.last
    end

    @selected_button.toggle
    @selected_button = nil

    if @game.questions.size == @game.num_questions
      end_quiz
    else
      gen_question
    end
  end

  def update
    return if @game.time_limit.zero?

    @tick += 1
    return unless (@tick % 60).zero? && (Time.now - @game.start_time).to_i > @game.time_limit

    puts 'Time limit exceeded'
    end_quiz
  end

  def start
    @game.questions = []
    @game.wrong_answers = []
    @game.score = 0
    gen_question
    @game.start_time = Time.now

    super
  end

  private

  def add_all
    @choice_buttons.each(&:add)
    @submit_button.add
    @question_display.each_value(&:add)
  end

  def remove_all
    @choice_buttons.each(&:remove)
    @submit_button.remove
    @question_display.each_value(&:remove)
  end

  def end_quiz
    puts 'Ending multiple choice quiz'
    @game.end_time = Time.now
    remove_all
    transition_to('GameOverGameState')
  end

  def gen_question
    op = @game.operators.sample

    case op
    when :+
      x = rand(@game.operand_min..@game.operand_max)
      y = rand(@game.operand_min..@game.operand_max)
    when :-
      x = rand(@game.operand_min..@game.operand_max)
      y = rand(@game.operand_min..@game.operand_max)
      # Ensure answer is non-negative
      if x < y
        tmp = x
        x = y
        y = tmp
      end
    when :*
      x = rand(@game.operand_min..@game.operand_max)
      y = rand(11)
    when :/
      # Ensure there is no remainder or division by 0
      y = [1, rand(@game.operand_min..@game.operand_max)].max
      x = y * rand(11)
    when :%
      x = rand(11..100)
      y = rand(1..10)
    end

    @game.questions << Question.new(x, y, op)

    choices = [@game.questions[-1].correct_answer]
    choices << off_by_few(choices[0])
    choices << off_by_ten(choices[0])
    choices << wrong_operation(x, y, op)
    choices.shuffle!

    (0..3).each do |i|
      @choice_buttons[i].text = (choices[i])
    end

    @question_display[:op1].text = (@game.questions[-1].x)
    @question_display[:op2].text = (@game.questions[-1].y)
    @question_display[:operator].text = (@game.questions[-1].operation)
  end

  def make_buttons
    @choice_buttons = []
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
      coords: { x: 85, y: 420 },
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
end
