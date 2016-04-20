# Copyright (c) 2012 Randy Carnahan <syn at dragonsbait dot com>
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the "Software"),
# to deal in the Software without restriction, including without limitation
# the rights to use, copy, modify, merge, publish, distribute, sublicense,
# and/or sell copies of the Software, and to permit persons to whom the
# Software is furnished to do so, subject to the following conditions:
#
# The above copyright notice and this permission notice shall be included
# in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN
# NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM,
# DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR
# OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE
# USE OR OTHER DEALINGS IN THE SOFTWARE.
#
# dicelib.rb -- version: 3.2.0

require 'parslet'

# This defined the main DiceBag module.
module DiceBag
  DEFAULT_ROLL = '1d6'.freeze

  # This is our generic DiceBagError
  # exception subclass.
  class DiceBagError < Exception; end

  ###
  # Module Methods
  ###

  # This takes the parsed tree, AFTER it has
  # been through the Transform class, and massages
  # the data a bit more, to ease the iteration that
  # happens in the Roll class. It will convert all
  # values into the correct *Part class.
  def self.normalize_tree(tree)
    tree = [tree] unless tree.first.is_a? Array

    tree.map { |part| normalize part }
  end

  def self.normalize(part)
    [
      normalize_op(part.first),
      normalize_value(part.last)
    ]
  end

  def self.normalize_op(op)
    # We swap out the strings for symbols.
    # If the op is not one of the arithimetic
    # operators, then the op itself is returned.
    # (This should only happen on :start arrays.)
    case op
    when '+' then :add
    when '-' then :sub
    when '*' then :mul
    when '/' then :div
    else
      op
    end
  end

  def self.normalize_value(val)
    case val
    when String
      LabelPart.new val
    when Hash
      RollPart.new normalize_xdx(val)
    else
      StaticPart.new val
    end
  end

  # This further massages the xDx hashes.
  def self.normalize_xdx(hash)
    count = hash[:xdx][:count]
    sides = hash[:xdx][:sides]

    # Delete the no longer needed :xdx key.
    hash.delete(:xdx)

    # Default to at least 1 die.
    count = 1 if count.zero? || count.nil?

    # Set the :count and :sides keys directly
    # and set the notes array.
    hash[:count] = count
    hash[:sides] = sides
    hash[:notes] = []

    normalize_options hash
  end

  def self.normalize_options(hash)
    if hash[:options].empty?
      hash.delete(:options)
    else
      normalize_explode hash
      normalize_reroll hash
      normalize_drop_keep hash
      normalize_target hash
    end

    hash
  end

  # Prevent Explosion abuse.
  def self.normalize_explode(xdx)
    return unless xdx[:options].key? :explode

    explode = xdx[:options][:explode]

    if explode.nil? || explode.zero? || explode == 1
      xdx[:options][:explode] = xdx[:sides]

      xdx[:notes].push("Explode set to #{xdx[:sides]}")
    end
  end

  # Prevent Reroll abuse.
  def self.normalize_reroll(xdx)
    return unless xdx[:options].key? :reroll

    if xdx[:options][:reroll] >= xdx[:sides]
      xdx[:options][:reroll] = 0

      xdx[:notes].push 'Reroll reset to 0.'
    end
  end

  # Make sure there are enough dice to
  # handle both Drop and Keep values.
  # If not, both are reset to 0. Harsh.
  def self.normalize_drop_keep(xdx)
    drop = xdx[:options].fetch(:drop, 0)
    keep = xdx[:options].fetch(:keep, 0)

    if (drop + keep) >= xdx[:count]
      xdx[:options][:drop] = 0
      xdx[:options][:keep] = 0

      xdx[:notes].push 'Drop and Keep Conflict. Both reset to 0.'
    end
  end

  # Finally, if we have a target number, make sure it is equal
  # to or less than the dice sides and greater than 0, otherwise,
  # set it to 0 (aka no target number) and add a note.
  def self.normalize_target(xdx)
    return unless xdx[:options].key? :target

    target = xdx[:options][:target]

    return if target >= 0 && target <= xdx[:sides]

    xdx[:options][:target] = 0

    xdx[:notes].push 'Target number too large or is negative; reset to 0.'
  end

  # This is the wrapper for the parse, transform,
  # and normalize calls. This is called by the Roll
  # class, but may be called to get the raw returned
  # array of parsed bits for other purposes.
  def self.parse(dstr = '')
    tree = Parser.new.parse(dstr)
    ast  = Transform.new.apply(tree)

    normalize_tree ast
  end
end

# Our sub-modules.
require_relative './dicebag/roll_string'
require_relative './dicebag/roll_part_string'
require_relative './dicebag/parser'
require_relative './dicebag/transform'
require_relative './dicebag/simple_part'
require_relative './dicebag/label_part'
require_relative './dicebag/static_part'
require_relative './dicebag/roll_part'
require_relative './dicebag/roll'
require_relative './dicebag/result'
