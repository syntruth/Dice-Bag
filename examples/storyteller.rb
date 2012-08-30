# This is actually modeling the "Storytelling" system dice, not the older
# "Storyteller" system dice, but I personally find "Storytelling" kind of a 
# silly name; prefer the older name. :D
require 'rubygems'
require 'dicebag'

module Storyteller
  class Pool < DiceBag::Roll
    def initialize(number=1, success=8)
      @number    = number
      @success   = success
      @successes = nil
      @tally     = nil

      super("#{number}d10e")
    end

    def roll
      @result    = super()
      @tally     = @result.sections.first.tally
      @successes = @tally.count {|r| r >= @success}

      return self
    end

    def successes
      self.roll unless @successes
      return @successes
    end

    def tally
      self.roll unless @tally
      return @tally
    end

    def to_s
      return "#{@number}d10/#{@success}"
    end
  end

  Chance = Pool.new(1, 10)
end
