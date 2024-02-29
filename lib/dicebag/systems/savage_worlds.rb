require 'dicebag'

module SavageWorlds
  # Models a single Savage World die, with attributes for max and half
  # values.
  #
  # Since all Savage Worlds Trait (Attributes + Skills) dice can
  # explode, that option is included automatically.
  class SWDie < DiceBag::Roll
    attr_reader :maximum
    attr_reader :half

    def initialize(sides, mod = 0)
      @maximum = sides
      @half    = (sides / 2) + (mod / 2)

      dstr = mod.zero? ? "1d#{sides}e" : "1d#{sides}e #{mod}"

      super(dstr)
    end
  end

  D4             = SWDie.new(4)
  D6             = SWDie.new(6)
  D8             = SWDie.new(8)
  D10            = SWDie.new(10)
  D12            = SWDie.new(12)
  WildDie        = SWDie.new(6)
  NoTrait        = SWDie.new(4, -2)
  NoTraitWildDie = SWDie.new(6, -2)
end
