require 'dicebag'

# This handles Fudge RPG type of rolls.
#
# This probably isn't (it *totally* isn't!) the most effecient way to do
# this, but shows how to examine DiceBag objects to get what you need
# for wonky dice systems.
module Fudge
  # This models a standard Fudge RPG dice pool.
  class Roll < DiceBag::Roll
    def initialize(number = 4)
      @number = number
      @total  = nil
      @tally  = nil

      # This is a very silly way to do this, since there is no need to
      # actually add the dice together here. But we need all of the d6's
      # together in the same roll.
      dstr = (['1d6'] * number).join(' + ')

      super(dstr)
    end

    def roll
      super

      generate_tally

      @total = @tally.count('+') - @tally.count('-')

      [@total, tally_to_s]
    end

    def total
      roll unless @total

      @total
    end

    def tally
      roll unless @tally

      @tally
    end

    def to_s
      base = "#{@number}dF"

      @total ? "#{base} #{tally_to_s} => #{@total}" : base
    end

    private

    def generate_tally
      @tally = @sections.map { |s| gen_symbol s.total }.sort.reverse
    end

    def gen_symbol(total)
      case total
      when 1, 2 then '-'
      when 3, 4 then ' '
      when 5, 6 then '+'
      end
    end

    def tally_to_s
      return '[]' unless @tally

      "[#{@tally.join('][')}]"
    end
  end

  DF = Roll.new

  def self.roll(num = 4)
    Roll.new(num).roll
  end
end
