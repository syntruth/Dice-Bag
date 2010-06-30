# Name   : Dice Library for Ruby
# Author : Randy Carnahan
# Version: 1.5
# License: LGPL

# This module is more or less intended as a mixin for your
# own classes; for example, see the Roll class below.
module Dice

  TEST_DSTR  = "6x 4d6 !3"
  TEST_DSTR2 = "2d10 e10"
  TEST_DSTR3 = "2d8 +4 r5"

  COMPLEX_DSTR = "[(Stats) #{TEST_DSTR}], [#{TEST_DSTR2}] + [#{TEST_DSTR3}]"

  EXPLODE_LIMIT = 20

  DICE_HELP = "The dice string is #x #d# e# *# +/-# !# r# where:\n" +
    "#x is how many times to roll.\n" +
    "#d# is standard dice notation.\n" +
    "e# will roll the die again if it is >= the explode value.\n" + 
    "*# is a multiplier, applied before...\n" +
    "+/-# ...the modifier.\n" +
    "!# means keep the best dice out of the set.\n" +
    "r# will reroll any value equal to or lower than the given value.\n" +
    "You can give a short text descriptor after the roll in parenthesis.\n" +
    "Example: (Roll Stats) 6x 4d6 !3 " + 
    "-- means roll 4d6, keep the best 3, 6 times."

  DICE_STRING_REGEX = /\]\s*([\+\-\,])\s*\[/

  DICE_REGEX = /(\d{1,2}x)?    # How many times?
    (\d{1,2})?[dD](\d{1,3}|\%) # The dice to roll, xDx format
    (e\d{0,2})?                # Explode value
    ([+-]\d{1,2})?             # The modifier
    (\*\d{1,2})?               # Multiplier
    (!\d{1,2})?                # Keep value
    (r\d{1,2})?                # Reroll value
  /x

  OPTION_DEFAULTS = {
    :do_sort => true,
    :do_tally => true
  }


  # Dice Error Exception
  class DiceError < Exception
    # nop
  end

  # DiceRoll Structure
  # This is returned from roll(), either a single
  # instance or an array of instances.
  DiceRoll = Struct.new(:dice_string, :total, :results, :desc)

  # Subclass of Hash to hold the parts of a dice
  # string, with defaults.
  class DiceParts < Hash
    def initialize
      self[:times]   = 1
      self[:num]     = 1
      self[:sides]   = 6
      self[:mod]     = 0
      self[:mult]    = 0
      self[:keep]    = 0
      self[:explode] = 0
      self[:reroll]  = 0
      self[:desc]    = ""
    end
  end

  # Class to hold the entire results from a given dice
  # string. Will contain the DiceRoll instances and total
  # from each section of a dice string.
  class Result

    attr :rolls
    attr :total

    def initialize(rolls=[], total=0)
      @rolls = rolls
      @total = total
    end

    def +(rolls=[])
      @rolls += rolls
      @total += get_subtotal(rolls)
    end

    def -(rolls=[])
      @rolls += rolls
      @total -= get_subtotal(rolls)
    end

  private

    def get_subtotal(rolls)
      return rolls.inject(0) {|t, roll| t += roll.total}
    end

  end

  ###########
  # Methods #
  ###########

  # This is the main roll() method. It takes either a dice
  # string or an instance of DiceParts, then delegates to the
  # correct method for resolution.
  # Raises DiceError if str_or_diceparts are not of those 
  # classes.
  def roll(str_or_diceparts)
    case str_or_diceparts
    when String
      return roll_dice_string(str_or_diceparts)
    when DiceParts
      return roll_dice_parts(str_or_diceparts)
    end

    # Oops, not the correct classes.
    raise DiceError, "Dice::roll() parameter is not a String or DiceParts."
  end

  # Remove spaces and down case.
  def clean_dice_string(dstr="")
    return dstr.dup.downcase.gsub(/\s+/, "")
  end

  # This parses a given string, returning an instance of
  # DiceParts, which holds the default values.
  def parse_dice_string(dstr="")
    dice_parts = DiceParts.new()

    clean_dstr = clean_dice_string(dstr)
    parts = DICE_REGEX.match(clean_dstr)

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
          i = i[1 .. -1] if i.match(/^[!*er]/)
          i.to_i
        end
      end
      
      dice_parts[:times]   = parts[0] if parts[0] > 0
      dice_parts[:num]     = parts[1] if parts[1] > 1
      dice_parts[:sides]   = parts[2] if parts[2] > 1
      dice_parts[:explode] = parts[3] if parts[3] > 1
      dice_parts[:mod]     = parts[4]
      dice_parts[:mult]    = parts[5] if parts[5] > 1
      dice_parts[:keep]    = parts[6] if parts[6] > 0
      dice_parts[:reroll]  = parts[7] if parts[7] > 0
    end

    # ...and now, see if we have a roll descriptor.
    desc = dstr.match(/^\((.*?)\)/)
    if desc and desc.captures.any?
      dice_parts[:desc] = desc.captures[0]
    end

    return dice_parts
  end

  # This builds a dice string based on the instance of 
  # DiceParts that should be like the one obtained from 
  # parse_dice_string().
  def build_dice_string(parts, no_spaces=true)
    s = ""

    sp = no_spaces ? "" : " "
    
    s += case parts[:times]
      when 0..1 then ""
      else parts[:times].to_s + "x#{sp}"
    end

    s += parts[:num].to_s if parts[:num] != 0
    s += "d"
    s += (parts[:sides] == 100 ? "%" : parts[:sides].to_s) if parts[:sides] != 0

    if parts[:explode] != 0
      s += "#{sp}e"
      s += parts[:explode].to_s if parts[:explode] != parts[:sides]
    end

    s += case parts[:mult]
      when 0..1 then ""
      else "#{sp}*" + parts[:mult].to_s
    end

    if parts[:mod] != 0
      s += (parts[:mod] > 0 ? "#{sp}+" : sp) + parts[:mod].to_s
    end

    s += "#{sp}!" + parts[:keep].to_s if parts[:keep] != 0

    s += "#{sp}r" + parts[:reroll].to_s if parts[:reroll] != 0

    return s
  end

  # Gets a random number, up to :sides. While that number is
  # lesser than or equal to :reroll, gets another number.
  def roll_die(sides=6, reroll=0)
    num = 0
    reroll = 0 if reroll >= sides
    while num <= reroll
      num = rand(sides) + 1
    end
    return num
  end

  # Takes an instance of DiceParts, that should have been 
  # returned from parse_dice_string() above. Returns an 
  # array of DiceRoll instances, unless :single_result is 
  # set to true, then only returns the first result, 
  # irregardless of the :times value in the DiceParts
  # instance.
  def roll_dice_parts(dice_parts, single_result=false, options = {})
    all_results = []

    opts = OPTION_DEFAULTS.dup.update(options)

    how_many = single_result ? 1 : dice_parts[:times]

    how_many.times do

      results = []
      total = 0

      dice_parts[:num].times do
        roll = roll_die(dice_parts[:sides], dice_parts[:reroll])
        results.push(roll)
        if dice_parts[:explode] and dice_parts[:explode] > 0
          explode_roll = 0
          while roll >= dice_parts[:explode]
            roll = roll_die(dice_parts[:sides], dice_parts[:reroll])
            results.push(roll)
            explode_roll += 1
            break if explode_roll >= EXPLODE_LIMIT
          end
        end
      end

      if opts[:do_tally]
        disp_results = results.dup()
        disp_results.sort!.reverse! if opts[:do_sort]
      else
        disp_results = nil
      end

      results.sort!.reverse!

      if dice_parts[:keep] > 0
        sub_results = results[0 ... dice_parts[:keep]]
      else
        sub_results = results.dup
      end
      
      total = sub_results.inject do |t, i|
        t += i
      end
      
      if dice_parts[:mult] > 1
        total = total * dice_parts[:mult]
      end
      
      if dice_parts[:mod] != 0
        total += dice_parts[:mod]
      end

      dstr = build_dice_string(dice_parts)

      res = DiceRoll.new(dstr, total, disp_results, dice_parts[:desc])
      all_results.push(res)
    end

    if single_result
      return all_results.first()
    else
      return all_results
    end
  end


  # Generates results based on a dice string. 
  # It will return an array of Result instances.
  def roll_dice_string(dstr="")
    results = []
      
    # Default operand is to add rolls.
    op = "+"

    rolls = dstr.split(DICE_STRING_REGEX).collect do |s|
      s.gsub(/[\[\] ]/, "")
    end

    current = Result.new()

    rolls.each do |str|
      
      case str
      when "+", "-"
        op = str

      when ","
        # Reset operand to add.
        op = "+"

        results.push(current)
        current = Result.new()

      else 
        roll = roll_dice_parts(parse_dice_string(str))
        current.send(op, roll)
      end
    end

    # Push our last Result.
    results.push(current)

    return results
  end

  # The following methods require a hash returned from
  # parse_dice_string() above.
  # These ignore any :times and :explode values, so these
  # won't be overly helpful in figuring out statistics
  # or anything.

  def maximum(dice)
    num = dice[:keep].zero? ? dice[:num] : dice[:keep]
    mult = dice[:mult].zero? ? 1 : dice[:mult]
    return ((num * dice[:sides]) * mult) + dice[:mod]
  end

  def minimum(dice)
    # Short-circuit-ish logic here; if :sides and :reroll
    # are the same, return maximum() instead.
    return maximum(dice) if dice[:sides] == dice[:reroll]

    num = dice[:keep].zero? ? dice[:num] : dice[:keep]
    mult = dice[:mult].zero? ? 1 : dice[:mult]
      
    # Reroll value is <=, so we have to add 1 to get 
    # the minimum value for the die.
    sides = dice[:reroll].zero? ? 1 : dice[:reroll] + 1

    return ((num * sides) * mult) + dice[:mod]
  end

  def average(dice)
    # Returns a float, of course.
    return (maximum(dice) + minimum(dice)) / 2.0
  end

# End Dice Module
end

module Roll

  # This class encapsulates a dice roll of a given
  # string, which can then be used to roll that 
  # "group" of dice over and over, with an optional
  # history of of the rolls.

  class Roll
    include Dice

    attr_reader :dice
    attr_reader :dice_parts
    attr_reader :history

    # Builds the Roll object. 
    # dstr is the dice string to roll. Note, this should not
    # be a complex dice string, but a simple one.
    # do_single, if set to true, will only return the first
    # result from an array of results.
    # history is how many results to remember from past rolls.
    # Set this to zero if you do not wish to keep a history of 
    # rolls.
    def initialize(dstr="1d6", do_single=false, history = 10)
      @dice_parts = parse_dice_string(dstr)
      @dice = build_dice_string(@dice_parts)
      @do_single_result = do_single
      @history = []
      @history_length = history
    end

    def roll(mod=0, single_result=false)
      mod = 0 if mod.class != Fixnum
      if mod.zero?
        parts = @dice_parts
      else
        parts = @dice_parts.dup()
        parts[:mod] += mod
      end

      # Fall back on the instance's result setting if the 
      # per-roll result is false.
      single_result = @do_single_result if not single_result

      result = roll_dice_parts(parts, single_result)

      self.add_history(result) unless @history_length.zero?

      return result
    end

    def add_history(result)
      @history.insert(0, result[0])
      @history.slice!(10, @history.length())
      return nil
    end

    def maximum
      return super(@dice_parts)
    end

    def minimum
      return super(@dice_parts)
    end

    def average
      return (self.maximum + self.minimum) / 2.0
    end

    def to_s
      return @dice
    end

  end

  class D4 < Roll
    def initialize
      super("d4", true)
    end
  end

  class D6 < Roll
    def initialize
      super("d6", true)
    end
  end

  class D8 < Roll
    def initialize
      super("d8", true)
    end
  end

  class D10 < Roll
    def initialize
      super("d10", true)
    end
  end

  class D12 < Roll
    def initialize
      super("d12", true)
    end
  end

  class D20 < Roll
    def initialize
      super("d20", true)
    end
  end

  class D30 < Roll
    def initialize
      super("d30", true)
    end
  end

  class D100 < Roll
    def initialize
      super("d100", true)
    end
  end

# End Roll Module
end

# Test Code
if __FILE__ == $0
  include Dice

  test_roll = Proc.new do |dstr|
    puts "Rolling for: #{dstr}"
    d = Dice::parse_dice_string(dstr)
    results = roll(d)
    for result in results
      puts "  Total: #{result[:total]}"
      puts "  Rolls: [" + result[:results].join("][") + "]"
      puts ""
    end
  end

  [TEST_DSTR, TEST_DSTR2, TEST_DSTR3].each do |dstr|
    test_roll.call(dstr)
  end

end

