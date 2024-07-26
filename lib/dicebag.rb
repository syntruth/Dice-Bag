require 'parslet'

# This defined the main DiceBag module.
module DiceBag
  # This is our generic DiceBagError exception subclass.
  class DiceBagError < StandardError; end

  # This is the wrapper for the parse, transform, and normalize calls.
  # This is called by the Roll class, but may be called to get the raw
  # returned array of parsed parts for other purposes.
  def self.parse(dstr = '')
    tree = Parser.new.parse(dstr)
    ast  = Transform.new.apply(tree)

    Normalize.call ast
  end

  ###
  # Main Syntatic Sugar Interface Methodds
  ###

  def self.roll(dstr)
    DiceBag::Roll.new(dstr).roll
  end

  def self.average(dstr)
    DiceBag::Roll.new(dstr).average
  end

  def self.maximum(dstr)
    DiceBag::Roll.new(dstr).maximum
  end

  def self.minimum(dstr)
    DiceBag::Roll.new(dstr).minimum
  end

  # The default roll if one is not given.
  def self.default_roll
    '1d6'
  end
end

# Our sub-modules.
require_relative 'dicebag/normalize'
require_relative 'dicebag/min_max_calc'
require_relative 'dicebag/roll_string'
require_relative 'dicebag/roll_part_string'
require_relative 'dicebag/parser'
require_relative 'dicebag/transform'
require_relative 'dicebag/simple_part'
require_relative 'dicebag/label_part'
require_relative 'dicebag/static_part'
require_relative 'dicebag/roll_part'
require_relative 'dicebag/roll'
require_relative 'dicebag/result'
