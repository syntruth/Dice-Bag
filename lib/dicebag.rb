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
# dicelib.rb -- version: 3.0.5

require 'parslet'

module DiceBag

  DefaultRoll = "1d6"

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
    return tree.collect do |part|

      case part
      when Hash
        if part.has_key?(:label)
          part = [:label, LabelPart.new(part[:label])]
        elsif part.has_key?(:start)
          xdx  = normalize_xdx(part[:start])
          part = [:start, RollPart.new(xdx)]
        end

      when Array
        # We swap out the strings for symbols.
        # If the op is not one of the arithimetic 
        # operators, then the op itself is returned.
        # (This should only happen on :start arrays.)

        op  = part.first
        val = part.last

        op = case op
        when "+" then :add
        when "-" then :sub
        when "*" then :mul
        when "/" then :div
        end
        
        # If the value is a hash, it's an :xdx hash.
        # Normalize it.
        if val.is_a?(Hash)
          xdx = normalize_xdx(val)
          val = RollPart.new(xdx)
        else
          val = StaticPart.new(val)
        end

        part = [op, val]
      end

      part
    end
  end

  # This further massages the xDx hashes.
  def self.normalize_xdx(xdx)
    count = xdx[:xdx][:count]
    sides = xdx[:xdx][:sides]
    notes = []

    # Default to at least 1 die.
    count = 1 if count.zero? or count.nil?

    # Set the :count and :sides keys directly
    # and get rid of the :xdx sub-hash.
    xdx[:count] = count
    xdx[:sides] = sides
    xdx.delete(:xdx)

    if xdx[:options].empty?
      xdx.delete(:options)
    else
      # VALIDATE ALL THE OPTIONS!!!

      # Prevent Explosion abuse.
      if xdx[:options].has_key?(:explode)
        explode = xdx[:options][:explode]

        if explode.nil? or explode.zero? or explode == 1
          xdx[:options][:explode] = sides
          notes.push("Explode set to #{sides}")
        end
      end

      # Prevent Reroll abuse.
      if xdx[:options].has_key?(:reroll) and xdx[:options][:reroll] >= sides
        xdx[:options][:reroll] = 0 
        notes.push("Reroll reset to 0.")
      end

      # Make sure there are enough dice to
      # handle both Drop and Keep values.
      # If not, both are reset to 0. Harsh.
      drop = xdx[:options][:drop] || 0
      keep = xdx[:options][:keep] || 0

      if (drop + keep) >= count
        xdx[:options][:drop] = 0
        xdx[:options][:keep] = 0
        notes.push("Drop and Keep Conflict. Both reset to 0.")
      end

      # Negate :drop. See why in RollPart#roll.
      xdx[:options][:drop] = -(drop)
    end

    xdx[:notes] = notes unless notes.empty?

    return xdx
  end

  # This is the wrapper for the parse, transform,
  # and normalize calls. This is called by the Roll
  # class, but may be called to get the raw returned
  # array of parsed bits for other purposes.
  def self.parse(dstr="")
    begin
      tree = Parser.new.parse(dstr)
      ast  = Transform.new.apply(tree)

      # Sometimes, we get a hash back, so wrap it as 
      # a single element array.
      ast = [ast] unless ast.is_a?(Array)
      
      return normalize_tree(ast)

    rescue Parslet::ParseFailed => reason
      # We're merely re-wrapping the error here to 
      # hide implementation from user who doesn't care
      # to read the source.
      raise DiceBagError, "Dice Parse Error for string: #{dstr}"
    end
  end
end 

require 'dicebag/parser'
require 'dicebag/transform'
require 'dicebag/simple_part'
require 'dicebag/label_part'
require 'dicebag/static_part'
require 'dicebag/roll_part'
require 'dicebag/roll'
require 'dicebag/result'

