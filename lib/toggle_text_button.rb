# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'ruby2d'
require 'rubocop'
require_relative 'text_display'

class ToggleTextButton < TextDisplay
  attr_reader :toggled

  # @param {String} image_path
  # @param {Hash{ x:, y: }} coords
  # @param {Hash{ x:, y: }} size
  def initialize(text: nil, coords: { x: 0, y: 0 }, size: { width: 100, height: 100 }, orientation: :center)
    @toggled = false
    super
  end

  def mouse_over?(mx, my)
    @enabled && mx >= @coords[:x] && mx <= @coords[:x] + @size[:width] && my >= @coords[:y] && my <= @coords[:y] + @size[:height]
  end

  def toggle
    @toggled = !@toggled

    @background.color = @toggled ? 'green' : 'silver'
  end
end
