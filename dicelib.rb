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

module DiceLib

  DefaultRoll = "1d6"

  DefaultOptions = {
    :drop    => 0,
    :keep    => 0,
    :explode => 0,
    :reroll  => 0,
  }

  ExplodeLimit = 20

  class DiceLibError < Exception; end

  class Parser < Parslet::Parser

    # Base rules.
    rule(:space?)  { str(' ').repeat }
    rule(:number)  { match('[0-9]').repeat(1) }
    rule(:number?) { number.maybe }

    # Label rule
    rule(:lparen) { str('(') }
    rule(:rparen) { str(')') }
    rule(:label) do
      lparen >> 
      match('[^()]').repeat(1).as(:label) >> 
      rparen >> 
      space?
    end

    # count and sides rules.
    rule(:count) { number?.as(:count) }
    rule(:sides) { match('[dD]') >> number.as(:sides) }

    # xDx Parts.
    rule(:xdx) { (count >> sides).as(:xdx) >> options? }

    # xdx Options.
    rule(:explode) { str('e') >> number?.as(:explode) }
    rule(:drop)    { str('~') >> number.as(:drop) }
    rule(:keep)    { str('!') >> number.as(:keep) }
    rule(:reroll)  { str('r') >> number.as(:reroll) }

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
    
    # Part
    rule(:part)  do
      space?                    >> 
      op                        >> 
      space?                    >> 
      (xdx | number).as(:value) >> 
      space?
    end

    rule(:parts) { xdx.as(:start) >> part.repeat }

    rule(:dice) { label.maybe >> parts  }

    root(:dice)
  end

  class Transform < Parslet::Transform

    def Transform.hashify_options(options)
      opts = {}
      options.each {|opt, val| opts[opt] = val}
      return opts
    end

    # Option transforms. For those in some xdx subtrees,
    # the Transform.hashify_options method is called.
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
    rule(:op => simple(:o), :value => simple(:v)) do
      [String(o), Integer(v)]      
    end

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

    rule(:label => simple(:s)) { {:label => String(s)} }

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

    rule(:start => subtree(:part)) do
      {:start => {
        :xdx     => part[:xdx],
        :options => Transform.hashify_options(part[:options])
        }
      }
    end

    # We have to match these this way; this is a pain 
    # in the ass of a match. >:E
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

    def initialize(part)
      @total  = nil
      @tally  = []
      @value  = part
      @count  = part[:xdx][:count]
      @sides  = part[:xdx][:sides]

      # Our Default Options
      @options = {
        :explode => 0,
        :drop    => 0,
        :keep    => 0,
        :reroll  => 0
      }

      if part.has_key?(:options)
        @options.update(part[:options])

        # Check for nil :explode and set it
        # to @sides.
        @options[:explode] = @sides if @options[:explode].nil?
      end
    end

    # Checks to see if this instance has rolled yet
    # or not.
    def has_rolled?
      return @total.nil? ? false : true
    end

    # Rolls a single die from the xDx string.
    def roll_die()
      num    = 0
      reroll = (@options[:reroll] >= self.sides) ? 0 : @options[:reroll]

      while num <= reroll
        num = rand(self.sides) + 1
      end

      return num
    end

    def roll
      results = []

      self.count.times do
        roll = self.roll_die()

        results.push(roll)

        if @options[:explode] > 0
          explode_limit = 0

          while roll >= @options[:explode]
            roll = self.roll_die()
            results.push(roll)
            explode_limit += 1
            break if explode_limit >= ExplodeLimit
          end
        end
      end

      @tally = results.dup()

      results.sort!

      if @options[:drop] > 0
        results = results[0 ... @options[:drop]]
      end

      results.reverse!

      if @options[:keep] > 0
        results = results[0 ... @options[:keep]]
      end

      # I think reduce(:+) is ugly, but it's very fast.
      @total = results.reduce(:+)

      return self
    end

    # Returns the tally from the roll. This is the entire
    # tally, even if a :keep or :drop options was given.
    def tally(do_sort=true)
      do_sort ?  @tally.dup.sort.reverse() : @tally
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

      s += "#{sp}~" + @options[:drop].to_s   unless @options[:drop].zero?
      s += "#{sp}!" + @options[:keep].to_s   unless @options[:keep].zero?
      s += "#{sp}r" + @options[:reroll].to_s unless @options[:reroll].zero?

      return s
    end

    def <=>(other)
      return self.total <=> other.total
    end
  end

  class Roll
    attr :dstr
    attr :tree

    def initialize(dstr=nil)
      @dstr   = dstr ||= DefaultRoll
      @tree   = DiceLib.parse(dstr)
      @result = nil
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
  end

  class Result 
    attr_reader :label
    attr_reader :total
    attr_reader :sections

    def initialize(label, total, sections)
      @label    = label
      @total    = total
      @sections = sections
    end
  end

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
        op = case part.first
        when "+" then :add
        when "-" then :sub
        when "*" then :mul
        when "/" then :div
        else part.first
        end

        val = part.last
        val = val.is_a?(Hash) ? RollPart.new(val) : StaticPart.new(val)

        part = [op, val]
      end

      part
    end
  end

  def self.normalize_xdx(xdx)
    if xdx[:options].to_s.strip.empty?
      xdx.delete(:options)
    else
      case xdx[:options]
      when Hash
        opts = {}

        xdx[:options].each do |opt, value|
          opts[opt] = value
        end

        xdx[:options] = opts

      when Array
        # Seriously, somehow these are not being
        # transformed from the parsing. No clue why.
        # This might be fixed now!
        opts = Transform.hashify_options(xdx[:options])
        xdx[:options] = opts
      end
    end

    return xdx
  end

  def self.parse(dstr="")
    begin
      tree = Parser.new.parse(dstr)
      ast  = Transform.new.apply(tree)
      ast  = normalize_tree(ast)

    rescue Parslet::ParseFailed => reason
      # We're merely re-wrapping the error here to 
      # hide implementation from user who doesn't care
      # to read the source.
      #raise DiceLibError, "Dice Parse Error: #{reason}"
      STDERR.write("Error: #{reason}\n")
    end
  end
end 

if $0 == __FILE__
  require 'pp'

  dstrs = [
    # Basic rolls.
    '(Damage) 2d10', 
    '4d6!3',
    
    # Complex ones!
    '5d6!3e + 4 - 1', 
    '(Complex!) 6d10~2e10 +5 + 1d6 r3 - 2'
  ]

  dstrs.each do |dstr|
    puts "Trying #{dstr}"

    roll = DiceLib::Roll.new(dstr)
    res  = roll.result()

    pp roll.tree
    puts "#{dstr}: #{res.total}"
    puts ""
  end
end

