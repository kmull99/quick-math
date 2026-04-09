# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'ruby2d'
require 'rubocop'
require_relative 'start_up_game_state'
require_relative 'choice_math_game_state'
require_relative 'type_math_game_state'
require_relative 'game_over_game_state'

class Game
  # Quiz options
  attr_accessor :operators, :operand_min, :operand_max, :num_questions, :time_limit
  # Quiz stats
  attr_accessor :questions, :wrong_answers, :score, :start_time, :end_time

  # @game_states
  # @active_game_state

  def initialize
    @game_states = {
      StartUpGameState: StartUpGameState.new(self),
      ChoiceMathGameState: ChoiceMathGameState.new(self),
      TypeMathGameState: TypeMathGameState.new(self),
      GameOverGameState: GameOverGameState.new(self)
    }

    transition_to('StartUpGameState')
  end

  def handle_key_event(key_event)
    quit if key_event.key == 'escape'

    @active_game_state.handle_key_event(key_event)
  end

  def handle_mouse_event(mouse_event)
    @active_game_state.handle_mouse_event(mouse_event)
  end

  def transition_to(game_state)
    @active_game_state&.stop
    @active_game_state = @game_states[game_state.to_sym]
    @active_game_state.start

    case game_state
    when 'StartUpGameState'
      puts 'Transitioning to Start Up game state'
    when 'ChoiceMathGameState'
      puts 'Transitioning to Choice Math game state'
    when 'TypeMathGameState'
      puts 'Transitioning to Type Math game state'
    when 'GameOverGameState'
      puts 'Transitioning to Game Over game state'
    end
  end

  def update
    @active_game_state.update
  end

  def quit
    puts "\nShutting Down"
    exit
  end
end
