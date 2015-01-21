# Encoding: UTF-8

require 'rubygems'
require 'dicebag'

# This handles Fudge RPG type of rolls.
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

      # This is a very silly way to do this, since there
      # is no need to actually add the dice together here.
      # But we need all of the d6's together in the same roll.
      dstr = (['1d6'] * number).join(' + ')

      super(dstr)
    end

    def roll
      generate_tally

      @total = @tally.count('+') - @tally.count('-')

      self
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
      "#{@number}dF"
    end

    private

    def generate_tally
      @tally = super.sections.map { |s| generate_symbol s.total }.sort.reverse
    end

    def generate_symbol(total)
      case total
      when 1, 2 then '-'
      when 3, 4 then ' '
      when 5, 6 then '+'
      end
    end
  end

  DF = Roll.new
end
