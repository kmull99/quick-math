# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'ruby2d'
require 'rubocop'

class GameState
  # @game
  # @tick

  def initialize(game, *args) # rubocop:disable Lint/UnusedMethodArgument
    @game = game

    remove_all
  end

  def handle_key_event(event)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def handle_mouse_event(event)
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def update
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def start
    @tick = 0
    add_all
  end

  def stop
    remove_all
  end

  def transition_to(state)
    @game.transition_to(state)
  end

  private

  def add_all
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end

  def remove_all
    raise NotImplementedError, "#{self.class} has not implemented method '#{__method__}'"
  end
end
