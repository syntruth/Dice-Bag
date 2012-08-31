# This handles Fudge RPG type of rolls.
# This probably isn't (it -totally- isn't!) the most effecient way to do 
# this, but shows how to examine DiceBag objects to get what you need 
# for wonky dice systems.

module Fudge
  class Roll < DiceBag::Roll
    def initialize(number=4)
      @number = number
      @total  = nil
      @tally  = nil

      # This is a very silly way to do this, since there
      # is no need to actually add the dice together here.
      # But we need all of the d6's together in the same roll.
      dstr = (["1d6"] * number).join(" + ")

      super(dstr)
    end

    def roll
      total = 0
      tally = []

      super.sections.each do |section|
        # 1, 2 = -1
        # 3, 4 =  0
        # 5, 6 = +1
        num = case section.total
        when 1, 2 then -1
        when 3, 4 then  0
        when 5, 6 then  1
        end

        total += num
        tally.push(num)
      end

      @total = total
      @tally = tally.sort.reverse

      return self
    end

    def total
      self.roll unless @total
      return @total
    end

    def tally
      self.roll unless @tally
      return @tally
    end
  end
end
