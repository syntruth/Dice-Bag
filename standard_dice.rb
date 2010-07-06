# This builds off the dicelib, constructing sub-classes of the Dice::Roll
# class for the standard dice: d4, d6, etc...

require "dicelib"

module Dice

  class Die < Roll
    def initialize(sides)
      super("1d#{sides}")
    end

    def roll(modifier=0)
      modifier = 0 if not modifier.is_a?(Fixnum)

      res = super()
      return res.first.total + modifier
    end
  end

  class D4 < Die
    def initialize
      super(4)
    end
  end

  class D6 < Die
    def initialize
      super(6)
    end
  end

  class D8 < Die
    def initialize
      super(8)
    end
  end

  class D10 < Die
    def initialize
      super(10)
    end
  end

  class D12 < Die
    def initialize
      super(12)
    end
  end

  class D20 < Die
    def initialize
      super(20)
    end
  end

  class D100 < Die
    def initialize
      super(100)
    end
  end

end
