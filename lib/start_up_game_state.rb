# frozen_string_literal: true

require 'rubocop'
require_relative 'game_state'

class StartUpGameState < GameState
  # @operator_buttons

  # @input_buttons
  # @input_button_values
  # @active_input_button
  # @active_input_button_changed

  # @quiz_type_buttons
  # @quiz_type_display
  # @selected_quiz_button

  # @confirmation_button

  def initialize(game)
    puts 'Initializing Start Up game state'

    make_operator_buttons
    make_input_buttons
    make_quiz_type_buttons
    make_confirmation_button

    super
  end

  def handle_key_event(event)
    return unless @active_input_button

    case event.key
    when 'backspace'
      text = @input_buttons[@active_input_button].text.delete(@input_button_values[@active_input_button].to_s)
      @input_button_values[@active_input_button] = 0
      @input_buttons[@active_input_button].text = "#{text}#{@input_button_values[@active_input_button]}"
    when 'delete'
      text = @input_buttons[@active_input_button].text.delete(@input_button_values[@active_input_button].to_s)
      @input_button_values[@active_input_button] = 0
      @input_buttons[@active_input_button].text = "#{text}#{@input_button_values[@active_input_button]}"
    when /[[:digit:]]/
      text = @input_buttons[@active_input_button].text.delete(@input_button_values[@active_input_button].to_s)

      if @active_input_button_changed
        @input_button_values[@active_input_button] = 0
        @active_input_button_changed = false
      end

      @input_button_values[@active_input_button] = [999, @input_button_values[@active_input_button] * 10 + event.key.to_i].min
      @input_buttons[@active_input_button].text = "#{text}#{@input_button_values[@active_input_button]}"
    end
  end

  def handle_mouse_event(event)
    @operator_buttons.each do |button|
      return button.toggle if button.mouse_over?(event.x, event.y)
    end

    @input_buttons.each do |key, button|
      next unless button.mouse_over?(event.x, event.y)

      return if key == @active_input_button # rubocop:disable Lint/NonLocalExitFromIterator

      @input_buttons[@active_input_button].toggle if @active_input_button
      @active_input_button = key
      @input_buttons[@active_input_button].toggle
      @active_input_button_changed = true
    end

    @quiz_type_buttons.each do |button|
      next unless button.mouse_over?(event.x, event.y)

      return if @selected_quiz_button == button # rubocop:disable Lint/NonLocalExitFromIterator

      @selected_quiz_button&.toggle
      @selected_quiz_button = button
      @selected_quiz_button.toggle
    end

    start_quiz if @confirmation_button.mouse_over?(event.x, event.y)
  end

  def update
    # Do nothing
  end

  private

  def add_all
    @operator_buttons.each(&:add)
    @input_buttons.each_value(&:add)
    @quiz_type_buttons.each(&:add)
    @quiz_type_display.add
    @confirmation_button.add
  end

  def remove_all
    @operator_buttons.each(&:remove)
    @input_buttons.each_value(&:remove)
    @quiz_type_buttons.each(&:remove)
    @quiz_type_display.remove
    @confirmation_button.remove
  end

  def make_operator_buttons
    @operator_buttons = []
    (0..3).each do |i|
      @operator_buttons << ToggleTextButton.new(
        coords: { x: 80 + i * 40, y: 15 },
        size: { width: 30, height: 30 }
      )
    end

    @operator_buttons[0].text = '+'
    @operator_buttons[0].toggle
    @operator_buttons[1].text = '-'
    @operator_buttons[1].toggle
    @operator_buttons[2].text = '*'
    @operator_buttons[3].text = '/'
  end

  def make_input_buttons
    @input_button_values = { min: 0, max: 20, num_questions: 20, time_limit: 180 }

    @input_buttons = {
      min: ToggleTextButton.new(
        text: "Min Value: #{@input_button_values[:min]}",
        coords: { x: 10, y: 60 },
        size: { width: 300, height: 50 },
        orientation: :left
      ),
      max: ToggleTextButton.new(
        text: "Max Value: #{@input_button_values[:max]}",
        coords: { x: 10, y: 120 },
        size: { width: 300, height: 50 },
        orientation: :left
      ),
      num_questions: ToggleTextButton.new(
        text: "Questions: #{@input_button_values[:num_questions]}",
        coords: { x: 10, y: 180 },
        size: { width: 300, height: 50 },
        orientation: :left
      ),
      time_limit: ToggleTextButton.new(
        text: "Time Limit: #{@input_button_values[:time_limit]}",
        coords: { x: 10, y: 240 },
        size: { width: 300, height: 50 },
        orientation: :left
      )
    }
  end

  def make_quiz_type_buttons
    @quiz_type_display = TextDisplay.new(
      text: 'Quiz Type',
      coords: { x: 65, y: 310 },
      size: { width: 190, height: 40 },
      background: false
    )

    @quiz_type_buttons = []
    @quiz_type_buttons << ToggleTextButton.new(
      text: 'Choice',
      coords: { x: 10, y: 360 },
      size: { width: 140, height: 50 }
    )

    @quiz_type_buttons << ToggleTextButton.new(
      text: 'Written',
      coords: { x: 160, y: 360 },
      size: { width: 140, height: 50 }
    )
  end

  def make_confirmation_button
    @confirmation_button = ToggleTextButton.new(
      text: 'Confirm',
      coords: { x: 85, y: 420 },
      size: { width: 160, height: 50 }
    )
  end

  def start_quiz
    # Set operators
    @game.operators = []
    @operator_buttons.each do |button|
      @game.operators << button.text.to_sym if button.toggled
    end
    return puts 'Please select at least one operator.' if @game.operators.empty?

    # Set operands
    @game.operand_min = @input_button_values[:min]
    @game.operand_max = @input_button_values[:max]
    return puts 'Operand max must be greater than or equal to operand min.' if @game.operand_min > @game.operand_max

    # Set number of questions
    @game.num_questions = @input_button_values[:num_questions]
    return puts 'Number of questions must be at least 1.' if @game.num_questions.zero?

    # Set time limit
    @game.time_limit = @input_button_values[:time_limit]

    # Set quiz type
    return puts 'Please select a quiz type.' unless @selected_quiz_button

    case @selected_quiz_button.text
    when 'Choice'
      puts 'Starting multiple choice quiz'
      transition_to('ChoiceMathGameState')
    when 'Written'
      puts 'Starting written quiz'
      transition_to('TypeMathGameState')
    end
  end
end
