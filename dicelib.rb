# Name   : Dice Library for Ruby
# Author : Randy Carnahan
# Version: 2.5
# License: LGPL

module Dice

  ####################
  ### Test Strings ###
  ####################

  TEST_COMPLEX = "(Attack) 1d20+8, (Damage) 2d8 + 8 + 1d6 - 3"
  TEST_SIMPLE  = "4d6 !3"

  #############
  # Constants #
  #############

  EXPLODE_LIMIT = 20

  #######################
  # Regular Expressions #
  #######################

  SECTION_REGEX = /([+-]|[0-9*!xder]+)/i

  ROLL_REGEX = /
    (\d{1,2})?d(\d{1,3}|\%)    # The dice to roll, xDx format
    (e\d{0,2})?                # Explode value
    (!\d{1,2})?                # Keep value
    (r\d{1,2})?                # Reroll value
    (\*\d{1,2})?               # Multiplier
  /xi

  ###########
  # Classes #
  ###########

  # This models a complex dice string result.
  class ComplexResult
    attr :total
    attr :sections
    attr :label
    attr :parsed

    def initialize(total=0, sections=[], label="", parsed=[])
      @total    = total
      @sections = sections
      @label    = label
      @parsed   = parsed
    end

    def to_s
      @label.empty? ? @total.to_s() : "%s: %s" % [@label, @total]
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
      return "(%s)" % @value
    end
  end

  # This represents a static, non-random number part
  # of the dice string.
  class StaticPart < SimplePart
    def initialize(num)
      num = num.to_i() if num.is_a?(String)
      @value = num
    end

    def total
      return @value
    end

    def to_s
      return @value.to_s()
    end
  end

  # This represents the xDx part of the dice string.
  # It takes the xDx part of the dice string and parses it
  # to get the individual parts. It also provides methods for
  # to get the roll result.
  class RollPart < SimplePart

    attr :total
    attr :parts

    def initialize(dstr)
      @result = []
      @total  = nil
      @tally  = []
      @value  = dstr

      # Our Default Values
      @parts = {
        :times   => 1,
        :num     => 1,
        :sides   => 6,
        :keep    => 0,
        :explode => 0,
        :reroll  => 0,
        :mult    => 0,
      }

      self.parse()
    end

    # Uses the ROLL_REGEX constant to parse the xDx string
    # into the individual parts.
    def parse()

      dstr = @value.dup.downcase.gsub(/\s+/, "")
      parts = ROLL_REGEX.match(dstr)

      # Handle any crunchy-bits we found.
      if parts
        parts = parts.captures.dup()

        # Handle special d% sides
        parts[2] = 100 if parts[2] == "%"

        # Handle exploding value set to nothing.
        # Set it to the max-value of the die.
        parts[3] = parts[2] if parts[3] == "e"

        # Convert them to numbers.
        parts.collect! do |i|
          if i.nil?
            i = 0
          else
            i.gsub(/^[!*er]/, "").to_i()
          end
        end
        
        @parts[:num]     = parts[0] if parts[0] > 1
        @parts[:sides]   = parts[1] if parts[1] > 1
        @parts[:explode] = parts[2] if parts[2] > 1
        @parts[:keep]    = parts[3] if parts[3] > 0
        @parts[:reroll]  = parts[4] if parts[4] > 0
        @parts[:mult]    = parts[5] if parts[5] > 1
      end

      return self
    end

    # Checks to see if this instance has rolled yet
    # or not.
    def has_rolled?
      return @result.empty? ? false : true
    end

    # Rolls a single die from the xDx string.
    def roll_die()
      num = 0
      reroll = (@parts[:reroll] >= @parts[:sides]) ? 0 : @parts[:reroll]

      while num <= reroll
        num = rand(@parts[:sides]) + 1
      end

      return num
    end

    # Rolls the dice, saving the results in the @result
    # instance variable. @result is cleared before the 
    # roll is handled.
    def roll
      results = []

      @parts[:num].times do
        roll = roll_die()

        results.push(roll)

        if @parts[:explode] > 0
          explode_limit = 0

          while roll >= @parts[:explode]
            roll = roll_die()
            results.push(roll)
            explode_limit += 1
            break if explode_limit >= EXPLODE_LIMIT
          end
        end
      end

      @tally = results.dup()
      results.sort!.reverse!

      if @parts[:keep] > 0
        results = results[0 ... @parts[:keep]]
      end
       
      @total = results.inject(0) {|t, i| t += i}
      @total = total * @parts[:mult] if @parts[:mult] > 1

      return self
    end

    # Returns the tally from the roll. This is the entire
    # tally, even if a :keep option was given.
    def tally(do_sort=true)
      return @tally.dup.sort.reverse() if do_sort
      return @tally
    end

    # Gets the total of the last roll; if there is no 
    # last roll, it calls roll() first.
    def total
      self.roll() if @total.nil?
      return @total
    end

    # The following methods ignore any :times and :explode 
    # values, so these won't be overly helpful in figuring 
    # out statistics or anything.

    def maximum()
      num = @parts[:keep].zero? ? @parts[:num] : @parts[:keep]
      mult = @parts[:mult].zero? ? 1 : @parts[:mult]
      return ((num * @parts[:sides]) * mult)
    end

    def minimum()
      # Short-circuit-ish logic here; if :sides and :reroll
      # are the same, return maximum() instead.
      return maximum() if @parts[:sides] == @parts[:reroll]

      num = @parts[:keep].zero? ? @parts[:num] : @parts[:keep]
      mult = @parts[:mult].zero? ? 1 : @parts[:mult]
        
      # Reroll value is <=, so we have to add 1 to get 
      # the minimum value for the die.
      sides = @parts[:reroll].zero? ? 1 : @parts[:reroll] + 1

      return ((num * sides) * mult)
    end

    def average()
      # Returns a float, of course.
      return (self.maximum() + self.minimum()) / 2.0
    end

    # This takes the @parts hash and recreates the xDx
    # string. Optionally, passing true to the method will
    # remove spaces form the finished string.
    def to_s(no_spaces=false)
      s = ""

      sp = no_spaces ? "" : " "
      
      s += @parts[:num].to_s if @parts[:num] != 0
      s += "d"
      s += @parts[:sides].to_s if @parts[:sides] != 0

      if @parts[:explode] != 0
        s += "#{sp}e"
        s += @parts[:explode].to_s if @parts[:explode] != @parts[:sides]
      end

      s += "#{sp}*" + @parts[:mult].to_s if @parts[:mult] > 1
      s += "#{sp}!" + @parts[:keep].to_s if @parts[:keep] != 0
      s += "#{sp}r" + @parts[:reroll].to_s if @parts[:reroll] != 0

      return s
    end

    def <=>(other)
      return self.total <=> other.total
    end
  end

  # Main class in the Dice module
  # This takes a complex dice string on instatiation,
  # parses it into it's individual parts, and then with
  # a call to the roll() method, will return an array of
  # results. Each element of the returned array will be an
  # instance of the ComplexResult structure, representing
  # a section of the complex dice string.
  class Roll
    attr :parsed

    def initialize(dstr="")
      @parsed = Dice.parse_dice_string(dstr)
      @result = []
    end

    def result
      self.roll() if @result.empty?
      return @result
    end

    def roll
      @result = []

      @parsed.each do |section|
        total    = 0
        sections = []
        label    = ""

        section.each do |op, part|
          
          # If this is a RollPart instance,
          # ensure fresh results.
          part.roll() if part.is_a?(RollPart)
            
          case op
          when :label
            label = part.value()
          when :start
            total = part.total()
            sections.push(part)
          when :add
            total += part.total()
            sections.push(part)
          when :sub
            total -= part.total()
            sections.push(part)
          end
        end

        res = ComplexResult.new(total, sections, label, section)

        @result.push(res)
      end

      return @result
    end

    # Recreates the complex dice string from the 
    # parsed array.
    def to_s
      return Dice.make_dice_string(@parsed)
    end

  end

  # This is a simplified subclass of Roll, for handling
  # simple dice strings, like a single die roll. This
  # operates just like the Roll class, except that it
  # has some methods to more easily pull totals and a tally
  # for the roll.
  # This is for -simple- dice rolls only, no static parts
  # or labels. Any extra parts are ignored.
  # For example: 
  #   SimpleRoll.new("1d20")
  #        -- or --
  #   SimpleRoll.new("1d6e")
  class SimpleRoll < Roll

    # Overrides the Roll#roll() method. Instead of returning
    # the result array, it instead calls the super's method
    # and then returns self.
    def roll
      super()
      return self
    end

    def tally
      self.roll() if @result.empty?
      return @result.first.sections.first.tally()
    end

    def total
      self.roll() if @result.empty?
      return @result.first.total 
    end
  end

  ##################
  # Module Methods #
  ##################

  # Parses a complex dice string made up of one or more
  # comma-separated parts, each with an optional label.
  #
  # Example complex dice string:
  #   (Attack) 1d20+8, (Damage) 2d8 + 8 + 1d6 - 3
  #
  # Parsed to:
  #   [
  #     [
  #       [:label, "Attack"],
  #       [:start, "1d20"],
  #       [:add,   "8"]
  #     ],
  #     [
  #       [:label, "Damage"],
  #       [:start, "2d8"],
  #       [:add,   "8"],
  #       [:add,   "1d6"],
  #       [:sub,   "3"]
  #     ]
  #   ]
  #
  # Each part (the 2nd element in each sub-array) is a 
  # subclass of SimplePart: LabelPart, StaticPart, or
  # RollPart.
  def Dice.parse_dice_string(dstr="")
    all = []

    # Get our sections.
    sections = dstr.split(/,/)

    sections.each do |subsec|
      sec = []
      
      # First we look for labels.
      labels = subsec.scan(/\((.*?)\)/).flatten()

      # ...and then remove them and any spaces.
      subsec.gsub!(/\(.*?\)|\s/, "")

      # Record the first label found.
      if not labels.empty?
        label = labels.first()
        sec.push([:label, LabelPart.new(label)])
      end

      subs = subsec.scan(SECTION_REGEX).flatten()

      op = :start

      subs.each do |s|
        case s
        when "+"
          op = :add
        when "-"
          op = :sub
        else
          value = get_part(s)
          sec.push [op, value]
        end
      end

      all.push(sec)

    end

    return all
  end

  # Examines the given string and determines with
  # subclass of SimplePart the part should be. If it
  # can't figure it out, it defaults to SimplePart.
  def Dice.get_part(dstr="")
    part = case dstr
    when /^\d+$/
      StaticPart.new(dstr)
    when ROLL_REGEX
      RollPart.new(dstr)
    else
      SimplePart.new(dstr)
    end
    return part
  end

  # Takes a nested array, such as that returned from
  # parse_dice_string() and recreates the dice string.
  def Dice.make_dice_string(arr=[])
    return "" if not arr.is_a?(Array) or arr.empty?
    return arr.collect {|part| make_substring(part)}.join(", ")
  end

  # Builds the individual section by calling
  # each part's to_s() method. Returns a string.
  def Dice.make_substring(arr=[])
    s = ""
    return s if not arr.is_a?(Array) or arr.empty?

    arr.each do |op, part|
      case op
      when :label, :start
        s += "%s "   % part.to_s()
      when :add
        s += "+ %s " % part.to_s()
      when :sub
        s += "- %s " % part.to_s()
      end
    end

    return s.strip()
  end

end
