require 'dicebag'

# Module for standard polyhedral dice types.
module Standard
  # Models a single, simple die.
  class Die < DiceBag::Roll
    def initialize(sides)
      super("1d#{sides}")
    end
  end

  D4   = Die.new(4)
  D6   = Die.new(6)
  D8   = Die.new(8)
  D10  = Die.new(10)
  D12  = Die.new(12)
  D20  = Die.new(20)
  D100 = Die.new(100)
end
