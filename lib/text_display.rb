# frozen_string_literal: true

# RUBY 2D has third party dependencies. Install them here:
# https://www.ruby2d.com/learn/get-started/#set-up-your-ruby-environment
require 'ruby2d'
require 'rubocop'

class TextDisplay
  @text = nil
  @coords = nil
  @size = nil
  @orientation = nil
  @background = nil
  @enabled = nil

  # @param {String} image_path
  # @param {Hash{ x:, y: }} coords
  # @param {Hash{ x:, y: }} size
  # @param {Boolean} background
  def initialize(text: nil, coords: { x: 0, y: 0 }, size: { width: 100, height: 100 }, orientation: :center, background: true)
    @coords = coords
    @size = size
    @orientation = orientation
    @background = background
    @enabled = true

    draw(text)
  end

  def text=(text)
    @text.text = text
    set_text_coords
  end

  def text
    @text.text
  end

  def add
    return if @enabled

    @text.add
    @background.add if @background # rubocop:disable Style/SafeNavigation
    @enabled = true
  end

  def remove
    return unless @enabled

    @text.remove
    @background.remove if @background # rubocop:disable Style/SafeNavigation
    @enabled = false
  end

  private

  def draw(text)
    @text = Text.new(
      text,
      x: @coords[:x], y: @coords[:y],
      color: 'black',
      style: 'bold',
      z: 2,
      size: 36
    )

    set_text_coords

    return unless @background

    @background = Rectangle.new(
      x: @coords[:x], y: @coords[:y],
      width: @size[:width], height: @size[:height],
      color: 'silver',
      z: 1
    )
  end

  def set_text_coords
    case @orientation
    when :left
      @text.x = @coords[:x]
    when :center
      @text.x = @coords[:x] + @size[:width] / 2 - @text.width / 2
    when :right
      @text.x = @coords[:x] + @size[:width] - @text.width
    end

    # Text height is always centered
    @text.y = @coords[:y] + @size[:height] / 2 - @text.height / 2
  end
end
