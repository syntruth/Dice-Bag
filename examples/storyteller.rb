# This is actually modeling the "Storytelling" system dice, not the older
# "Storyteller" system dice, but I personally find "Storytelling" kind of a 
# silly name; prefer the older name. :D
require 'rubygems'
require 'dicebag'

module Storyteller
  class Pool < DiceBag::Roll
    def initialize(number=1, success=8)
      @number  = number
      @success = success
      @result  = nil

      super("#{number}d10e t#{success}")
    end

    def roll
      @result = super()
      return @result
    end

    def successes
      self.roll unless @result
      return @result.total
    end

    def tally
      self.roll unless @result
      return @result.sections[0].tally
    end

    def to_s
      return "#{@number}d10/#{@success}"
    end
  end

  Chance = Pool.new(1, 10)
end
