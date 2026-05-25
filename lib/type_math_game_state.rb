# frozen_string_literal: true

require 'rubocop'
require_relative 'game_state'

class TypeMathGameState < GameState
  # @question_display
  # @input_display
  # @submit_button

  def initialize(game)
    puts 'Initializing Type Math game state'

    make_buttons
    make_display

    super
  end

  def handle_key_event(event)
    case event.key
    when 'return'
      return if @input_display.text.empty?

      @game.questions[-1].answer(@input_display.text)
      if @game.questions[-1].grade
        @game.score += 1
      else
        @game.wrong_answers << @game.questions.last
      end

      if @game.questions.size == @game.num_questions
        end_quiz
      else
        @input_display.text = ('')
        gen_question
      end
    when 'backspace'
      tmp = @input_display.text
      return if tmp.empty?

      @input_display.text = (tmp[0..-2])
    when /[[:digit:]]/
      # Numpad keys print 'keypad #'
      # key[-1] accounts for both numpad & numrow
      @input_display.text = ("#{@input_display.text}#{event.key[-1]}")
    end
  end

  def handle_mouse_event(event)
    return unless @submit_button.mouse_over?(event.x, event.y)

    @game.questions[-1].answer(@input_display.text)
    if @game.questions[-1].grade
      @game.score += 1
    else
      @game.wrong_answers << @game.questions.last
    end

    if @game.questions.size == @game.num_questions
      end_quiz
    else
      @input_display.text = ('')
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
    @question_display.each_value(&:add)
    @input_display.add
    @submit_button.add
  end

  def remove_all
    @question_display.each_value(&:remove)
    @input_display.remove
    @submit_button.remove
  end

  def end_quiz
    puts 'Ending written quiz'
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

    @question_display[:op1].text = (@game.questions[-1].x)
    @question_display[:op2].text = (@game.questions[-1].y)
    @question_display[:operator].text = (@game.questions[-1].operation)
  end

  def make_buttons
    @submit_button = ToggleTextButton.new(
      text: 'Submit',
      coords: { x: 85, y: 420 },
      size: { width: 150, height: 50 }
    )
  end

  def make_display
    @question_display = {
      op1: TextDisplay.new(
        coords: { x: 135, y: 150 },
        size: { width: 50, height: 50 },
        background: false,
        orientation: :right
      ),
      op2: TextDisplay.new(
        coords: { x: 135, y: 200 },
        size: { width: 50, height: 50 },
        background: false,
        orientation: :right
      ),
      operator: TextDisplay.new(
        coords: { x: 90, y: 200 },
        background: false,
        size: { width: 50, height: 50 }
      ),
      equal_bar: Rectangle.new(
        x: 95, y: 240,
        width: 100, height: 5,
        color: 'black'
      )
    }

    @input_display = TextDisplay.new(
      coords: { x: 85, y: 250 },
      size: { width: 100, height: 50 },
      background: false,
      orientation: :right
    )
  end
end
