require 'dicebag'

# This is actually modeling the "Storytelling" system dice, not the
# older "Storyteller" system dice, but I personally find "Storytelling"
# kind of a silly name, so I prefer the older name. :D
module Storyteller
  # This is a models a pool of Storyteller dice.
  class Pool < DiceBag::Roll
    def initialize(number = 1, success = 8)
      @number  = number
      @success = success
      @result  = nil

      super("#{number}d10e t#{success}")
    end

    def roll
      @result = super
    end

    def successes
      roll unless @result

      @result.total
    end

    def tally
      roll unless @result

      @result.sections[0].tally
    end

    def to_s
      "#{@number}d10/#{@success}"
    end
  end

  def self.roll(number = 1, success = 8)
    Pool.new(number, success).roll
  end

  def self.chance
    Pool.new(1, 10).roll
  end
end
