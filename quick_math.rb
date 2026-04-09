# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'ruby2d'
require 'rubocop'
require './lib/question'
require './lib/text_display'
require './lib/toggle_text_button'
require './lib/game'

@game = nil

def main
  set title: 'Quick Math',
      background: 'gray',
      width: 320,
      height: 480,
      resizable: false

  on :key_down do |key_event|
    @game.handle_key_event(key_event)
  end

  on :mouse_down do |mouse_event|
    @game.handle_mouse_event(mouse_event)
  end

  update do
    @game.update
  end

  @game = Game.new

  show
end

main
