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
# dicelib.rb -- version: 3.0

require 'rubygems'
require 'parslet'

module DiceBag

  DefaultRoll = "1d6"

  class DiceError < Exception; end

  class Parser < Parslet::Parser

    # Base rules.
    rule(:space?)  { str(' ').repeat }

    # Numbers are limited to 3 digit places. Why?
    # To prevent abuse from people rolling: 
    # 999999999D999999999 and 'DOS'-ing the app.
    rule(:number)  { match('[0-9]').repeat(1,3) }
    rule(:number?) { number.maybe }

    # Label rule
    # Labels must match '(<some text here>)' and
    # are not allowed to have commas in the label.
    # This for future use of parsing multiple dice
    # definitions in comma-separated strings.
    # The :label matches anything that ISN'T a 
    # parenethesis or a comma.
    rule(:lparen) { str('(') }
    rule(:rparen) { str(')') }
    rule(:label) do
      lparen >> 
      match('[^(),]').repeat(1).as(:label) >> 
      rparen >> 
      space?
    end

    # count and sides rules.
    # :count is allowed to be nil, which will default
    # to 1.
    rule(:count) { number?.as(:count) }
    rule(:sides) { match('[dD]') >> number.as(:sides) }

    # xDx Parts.
    # All xDx parts may be followed by none, one, or more
    # options.
    rule(:xdx) { (count >> sides).as(:xdx) >> options? }

    # xdx Options.
    # Note that :explode is allowed to NOT have a number
    # assigned, which will leave it with a nil value.
    # This is handled in RollPart#initialize.
    rule(:explode) { str('e') >> number?.as(:explode) >> space? }
    rule(:drop)    { str('~') >> number.as(:drop) >> space? }
    rule(:keep)    { str('!') >> number.as(:keep) >> space? }
    rule(:reroll)  { str('r') >> number.as(:reroll) >> space? }

    # This allows options to be defined in any order and
    # even have more than one of the same option, however
    # only the last option of a given key will be kept.
    rule(:options) { 
      space? >> (drop | explode | keep | reroll).repeat >> space?
    }

    rule(:options?) { options.maybe.as(:options) }

    # Part Operators.
    rule(:add) { str('+') }
    rule(:sub) { str('-') }
    rule(:mul) { str('*') }
    rule(:div) { str('/') }
    rule(:op)  { (add | sub | mul | div).as(:op) }
    
    # Part Rule
    # A part is an operator, followed by either an xDx
    # string or a static number value.
    rule(:part)  do
      space?                    >> 
      op                        >> 
      space?                    >> 
      (xdx | number).as(:value) >> 
      space?
    end

    # All parts of a dice roll MUST start with an xDx
    # string and then followed by any optional parts.
    # The first xDx string is labeled as :start.
    rule(:parts) { xdx.as(:start) >> part.repeat }

    # A dice string is an optional label, followed by
    # the defined parts.
    rule(:dice) { label.maybe >> parts  }

    root(:dice)
  end

  class Transform < Parslet::Transform

    def Transform.hashify_options(options)
      opts = {}
      options.each {|opt, val| opts[opt] = val} if options.is_a?(Hash)
      return opts
    end

    # Option transforms. These are turned into an array of
    # 2-element arrays ('tagged arrays'), which is then
    # hashified later. (There is no way to update the 
    # options when these rules are matched.)
    rule(:drop    => simple(:x)) { [:drop,    Integer(x)] }
    rule(:keep    => simple(:x)) { [:keep,    Integer(x)] }
    rule(:reroll  => simple(:x)) { [:reroll,  Integer(x)] }
    
    # Explode is special, in that if it is nil, then it
    # must remain that way.
    rule(:explode => simple(:x)) do
      x.nil? ? [:explode, nil] : [:explode, Integer(x)]
    end

    # Parts {:ops => (:xdx | :number)}
    # These are first-match, so the simple number will
    # be matched before the xdx subtree.

    # Match an operator followed by a static number.
    rule(:op => simple(:o), :value => simple(:v)) do
      [String(o), Integer(v)]
    end

    # Match an operator followed by an :xdx subtree.
    rule(:op => simple(:o), :value => subtree(:part)) do
      [String(o), 
        {
          :xdx => {
            :count => Integer(part[:xdx][:count]),
            :sides => Integer(part[:xdx][:sides])
          },
          :options => Transform.hashify_options(part[:options])
        }
      ] 
    end

    # Match a label by itself.
    rule(:label => simple(:s)) { {:label => String(s)} }

    # Match a label followed by a :start subtree.
    rule(:label => simple(:s), :start => subtree(:part)) do
      [
        {:label => String(s)},
        {:start => {
          :xdx     => part[:xdx],
          :options => Transform.hashify_options(part[:options])
          }
        }
      ]
    end

    # Match a :start subtree, with the label not present.
    # Note that this returns a hash, but the final output
    # will still be in an array.
    rule(:start => subtree(:part)) do
      {:start => {
        :xdx     => part[:xdx],
        :options => Transform.hashify_options(part[:options])
        }
      }
    end

    # Convert the count and sides of an :xdx part.
    rule(:count => simple(:c), :sides => simple(:s)) do
      { :count => Integer(c), :sides => Integer(s) }
    end
  end

  # The most simplest of a part. If a given part of
  # a dice string is not a Label, Fixnum, or a xDx part
  # it will be an instance of this class, which simply
  # returns the value given to it.
  class SimplePart
    attr :value

    def initialize(part)
      @value = part
    end

    def result
      return @value
    end

    def to_s
      return @value
    end
  end

  # The subclass for a label.
  class LabelPart < SimplePart
    def to_s
      return "(%s)" % self.value
    end
  end

  # This represents a static, non-random number part
  # of the dice string.
  class StaticPart < SimplePart
    def initialize(num)
      num    = num.to_i() if num.is_a?(String)
      @value = num
    end

    def total
      return self.value
    end

    def to_s
      return self.value.to_s()
    end
  end

  # This represents the xDx part of the dice string.
  class RollPart < SimplePart

    attr :count
    attr :sides
    attr :parts
    attr :options

    def initialize(part)
      @total  = nil
      @tally  = []
      @value  = part
      @count  = part[:count]
      @sides  = part[:sides]
      @notes  = part[:notes] || []

      # Our Default Options
      @options = {
        :explode => 0,
        :drop    => 0,
        :keep    => 0,
        :reroll  => 0
      }

      @options.update(part[:options]) if part.has_key?(:options)
    end

    def notes
      return @notes.join("\n") unless @notes.empty?
      return ""
    end

    # Checks to see if this instance has rolled yet
    # or not.
    def has_rolled?
      return @total.nil? ? false : true
    end

    # Rolls a single die from the xDx string.
    def roll_die()
      num    = 0
      reroll = @options[:reroll]

      while num <= reroll
        num = rand(self.sides) + 1
      end

      return num
    end

    def roll
      results = []
      explode = @options[:explode]

      self.count.times do
        roll = self.roll_die()

        results.push(roll)

        unless explode.zero?
          while roll >= explode
            roll = self.roll_die()
            results.push(roll)
          end
        end
      end

      results.sort!
      results.reverse!

      # Save the tally in case it's requested later.
      @tally = results.dup()

      # Drop the low end numbers if :drop is less than zero.
      if @options[:drop] < 0
        results = results[0 ... @options[:drop]]
      end

      # Keep the high end numbers if :keep is greater than zero.
      if @options[:keep] > 0
        results = results[0 ... @options[:keep]]
      end

      # I think reduce(:+) is ugly, but it's very fast.
      @total = results.reduce(:+)

      return self
    end

    # Returns the tally from the roll. This is the entire
    # tally, even if a :keep or :drop options were given.
    def tally()
      return @tally
    end

    # Gets the total of the last roll; if there is no 
    # last roll, it calls roll() first.
    def total
      self.roll() if @total.nil?
      return @total
    end

    # This takes the @parts hash and recreates the xDx
    # string. Optionally, passing true to the method will
    # remove spaces form the finished string.
    def to_s(no_spaces=false)
      s = ""

      sp = no_spaces ? "" : " "
      
      s += self.count.to_s unless self.count.zero?
      s += "d"
      s += self.sides.to_s

      unless @options[:explode].zero?
        s += "#{sp}e"
        s += @options[:explode].to_s unless @options[:explode] == self.sides
      end

      s += "#{sp}~" + @options[:drop].abs.to_s unless @options[:drop].zero?
      s += "#{sp}!" + @options[:keep].to_s     unless @options[:keep].zero?
      s += "#{sp}r" + @options[:reroll].to_s   unless @options[:reroll].zero?

      return s
    end

    def <=>(other)
      return self.total <=> other.total
    end
  end

  # This is the 'main' class of DiceLib. This class
  # takes the dice string, parses it, and encapsulates
  # the actual rolling of the dice. If no dice string
  # is given, it defaults to DefaultRoll.
  class Roll
    attr :dstr
    attr :tree

    alias :parsed :tree

    def initialize(dstr=nil)
      @dstr   = dstr ||= DefaultRoll
      @tree   = Dice.parse(dstr)
      @result = nil
    end

    def notes
      s = ""

      self.tree.each do |op, part|
        if part.is_a?(RollPart)
          n  = part.notes
          s += "For: #{part}:\n#{n}\n\n" unless n.empty?
        end
      end

      return s
    end

    def result
      self.roll() unless @result
      return @result
    end

    def roll
      total    = 0
      label    = ""
      sections = []
    
      self.tree.each do |op, part|
        do_push = true
 
        # If this is a RollPart instance,
        # ensure fresh results.
        part.roll() if part.is_a?(RollPart)

        case op
        when :label
          label   = part.value()
          do_push = false
        when :start
          total = part.total()
        when :add
          total += part.total()
        when :sub
          total -= part.total()
        when :mul
          total *= part.total()
        when :div
          total /= part.total()
        end

        sections.push(part) if do_push
      end

      @result = Result.new(label, total, sections)

      return @result
    end

    def to_s(with_space=true)
      s = ""

      sp = with_space ? ' ' : ''

      self.tree.each do |op, value|
        case op
        when :label
          s += "#{value}#{sp}"
        when :start
          s += "#{value}#{sp}"
        when :add
          s += "+#{sp}#{value}#{sp}"
        when :sub
          s += "-#{sp}#{value}#{sp}"
        when :mul
          s += "*#{sp}#{value}#{sp}"
        when :div
          s += "/#{sp}#{value}#{sp}"
        end
      end

      return s.strip
    end
  end

  # This class merely encapsulates the result,
  # providing convience methods to access the
  # results of each section if desired.
  class Result 
    attr_reader :label
    attr_reader :total
    attr_reader :sections

    def initialize(label, total, sections)
      @label    = label
      @total    = total
      @sections = sections
    end

    def each(&block)
      self.sections.each do |section|
        yield section
      end
      return nil
    end

    def to_s
      return "#{self.label}: #{self.total}"
    end
  end

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
        op = case part.first
        when "+" then :add
        when "-" then :sub
        when "*" then :mul
        when "/" then :div
        else part.first
        end

        val = part.last
        
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
    # and get ride of the :xdx sub-hash.
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
      
      return normalize_tree(ast)

    rescue Parslet::ParseFailed => reason
      # We're merely re-wrapping the error here to 
      # hide implementation from user who doesn't care
      # to read the source.
      raise DiceError, "Dice Parse Error for string: #{dstr}"
    end
  end
end 

# Ignore this. >.>  Lazy development testing.
if $0 == __FILE__
  require 'pp'

  dstrs = [
    # Basic rolls.
    '(Damage) 2d10', 
    '4d6!3',
    '1d100',
    
    # Complex ones!
    '5d6!3e + 4 - 1', 
    '(Complex!) 6d10~2e10 +5 + 1d6 r3 - 2'
  ]

  dstrs.each do |dstr|
    puts "Trying #{dstr}"

    roll = DiceBag::Roll.new(dstr)
    res  = roll.result()

    pp roll.tree
    puts "#{dstr}: #{res.total}"
    puts ""
  end
end

