# frozen_string_literal: true

require 'rubocop'
require_relative 'game_state'

class GameOverGameState < GameState
  # @score_display

  # @question_display
  # @current_question
  # @previous_question_button
  # @next_question_button

  # @play_again_button

  def initialize(game)
    puts 'Initializing Game Over game state'

    make_buttons
    make_score_display
    make_question_display

    super
  end

  def handle_key_event(event)
    case event.key
    when 'right'
      display_next_question
    when 'left'
      display_previous_question
    end
  end

  def handle_mouse_event(event)
    transition_to('StartUpGameState') if @play_again_button.mouse_over?(event.x, event.y)
    display_previous_question if @previous_question_button.mouse_over?(event.x, event.y)
    display_next_question if @next_question_button.mouse_over?(event.x, event.y)
  end

  def update
    return if @tick > 180

    @tick += 1
    @play_again_button.add if @tick >= 180
  end

  private

  def add_all
    @score_display.each_value(&:add)
    # @play_again_button.add
    set_display

    return if @game.wrong_answers.empty?

    @question_display.each_value(&:add)
    # @previous_question_button.add
    @next_question_button.add if @game.wrong_answers.size > 1
  end

  def remove_all
    @score_display.each_value(&:remove)
    @question_display.each_value(&:remove)
    @play_again_button.remove
    @next_question_button.remove
    @previous_question_button.remove
  end

  def display_next_question
    return unless @current_question_index < @game.wrong_answers.size - 1

    @current_question_index += 1
    set_question_display(@current_question_index)

    @previous_question_button.add if @current_question_index == 1
    @next_question_button.remove if @current_question_index == @game.wrong_answers.size - 1
  end

  def display_previous_question
    return if @current_question_index.zero?

    @current_question_index -= 1
    set_question_display(@current_question_index)

    @previous_question_button.remove if @current_question_index.zero?
    @next_question_button.add if @current_question_index == @game.wrong_answers.size - 2
  end

  def make_buttons
    @play_again_button = ToggleTextButton.new(
      text: 'Play Again',
      coords: { x: 60, y: 420 },
      size: { width: 200, height: 50 }
    )
    @next_question_button = ToggleTextButton.new(
      text: '>',
      coords: { x: 245, y: 305 },
      size: { width: 50, height: 50 }
    )
    @previous_question_button = ToggleTextButton.new(
      text: '<',
      coords: { x: 25, y: 305 },
      size: { width: 50, height: 50 }
    )
  end

  def make_question_display
    @question_display = {
      op1: TextDisplay.new(
        text: '00',
        coords: { x: 135, y: 255 },
        size: { width: 50, height: 50 },
        background: false,
        orientation: :right
      ),
      op2: TextDisplay.new(
        text: '00',
        coords: { x: 135, y: 305 },
        size: { width: 50, height: 50 },
        background: false,
        orientation: :right
      ),
      operator: TextDisplay.new(
        text: '+',
        coords: { x: 90, y: 305 },
        size: { width: 50, height: 50 },
        background: false
      ),
      equal_bar: Rectangle.new(
        x: 95, y: 350,
        width: 100, height: 5,
        color: 'black'
      ),
      answer: TextDisplay.new(
        text: '00',
        coords: { x: 100, y: 355 },
        size: { width: 85, height: 50 },
        background: false,
        orientation: :right
      )
    }
  end

  def make_score_display
    @score_display = {
      score: TextDisplay.new(
        coords: { x: 10, y: 10 },
        size: { width: 300, height: 50 },
        background: true,
        orientation: :left
      ),
      wrong: TextDisplay.new(
        coords: { x: 10, y: 70 },
        size: { width: 300, height: 50 },
        background: true,
        orientation: :left
      ),
      unanswered: TextDisplay.new(
        coords: { x: 10, y: 130 },
        size: { width: 300, height: 50 },
        background: true,
        orientation: :left
      ),
      message: TextDisplay.new(
        coords: { x: 10, y: 190 },
        size: { width: 300, height: 50 },
        background: true
      )
    }
  end

  def set_display
    @score_display[:score].text = "Score: #{@game.score}/#{@game.num_questions}"
    @score_display[:wrong].text = "Wrong: #{@game.wrong_answers.size}"
    @score_display[:unanswered].text = "Timed Out: #{@game.num_questions - @game.score - @game.wrong_answers.size}"

    @current_question_index = 0
    if @game.wrong_answers.empty?
      @score_display[:message].text = if @game.score == @game.questions.size
                                        'Perfect Score!'
                                      else
                                        'Out of Time'
                                      end
    else
      @score_display[:message].text = 'Please Review:'
      set_question_display(@current_question_index) unless @game.wrong_answers.empty?
    end
  end

  def set_question_display(index)
    @question_display[:op1].text = @game.wrong_answers[index].x
    @question_display[:op2].text = @game.wrong_answers[index].y
    @question_display[:operator].text = @game.wrong_answers[index].operation
    @question_display[:answer].text = @game.wrong_answers[index].correct_answer
  end
end
