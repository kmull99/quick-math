# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'ruby2d'
require 'rubocop'

class ToggleTextButton
  @coords = nil
  @size = nil

  @background = nil
  @text = nil

  @toggled = false

  # @param {String} image_path
  # @param {Hash{ x:, y: }} coords
  # @param {Hash{ x:, y: }} size
  def initialize(text: nil, coords: { x: 0, y: 0 }, size: { width: 100, height: 100 }, background: true)
    @coords = coords
    @size = size
    @background = true unless background

    draw(text)
  end

  def mouse_over?(mx, my)
    mx >= @coords[:x] && mx <= @coords[:x] + @size[:width] && my >= @coords[:y] && my <= @coords[:y] + @size[:height]
  end

  def set_text(text)
    @text.text = text
    set_text_coords
  end

  def get_text
    @text.text
  end

  def toggle
    @toggled = !@toggled

    @background.color = @toggled ? 'green' : 'silver'
  end

  private

  def draw(text)
    # return if @background

    @background ||= Rectangle.new(
      x: @coords[:x], y: @coords[:y],
      width: @size[:width], height: @size[:height],
      color: 'silver',
      z: 1
    )

    @text = Text.new(
      text,
      x: @coords[:x], y: @coords[:y],
      color: 'black',
      style: 'bold',
      z: 2,
      size: 36
    )

    set_text_coords
  end

  def set_text_coords
    @text.x = @coords[:x] + @size[:width] / 2 - @text.width / 2
    @text.y = @coords[:y] + @size[:height] / 2 - @text.height / 2
  end
end
