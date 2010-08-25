require "dicelib"

module Dice

  # A Subclass of Dice::Roll to add a few helper methods.
  # Can't use a SimpleRoll instance, due to No Trait rolls
  # having a static -2 modifier to the dice roll.
  class SWRoll < Roll

    attr_reader :value

    def initialize(dstr)
      super(dstr)
      @value = Dice.maximum(dstr)
      @sw_result = nil
    end

    def half_value
      return @value / 2
    end

    def roll
      @sw_result = super()
      return self
    end

    def total
      self.roll if @sw_result.nil?
      return @sw_result.first.total()
    end

    def tally
      self.roll if @sw_result.nil?
      return self.result.first.sections.first.tally()
    end

  end

  # A hash that holds the allowed dice in SW (the keys) and their
  # associated roll instances (the values.) See the +dicelib+ for more
  # information in regards to the +Roll::Roll+ class.
  AllowedDice = {
    :d4  => SWRoll.new("d4e"),
    :d6  => SWRoll.new("d6e"),
    :d8  => SWRoll.new("d8e"),
    :d10 => SWRoll.new("d10e"),
    :d12 => SWRoll.new("d12e")
  }

  # Because Ruby doesn't guarantee Hash keys will stay
  # in order, we'll use this array instead!
  # TODO: Perhaps use +SortedSet+ here instead.
  AllowedDiceOrder = [:d4, :d6, :d8, :d10, :d12]

  # Sets the roll values for the Wild Die, No Trait, and the Wild Die
  # With No Trait.
  WildDie        = SWRoll.new("d6e")
  NoTrait        = SWRoll.new("d4e-2")
  WildDieNoTrait = SWRoll.new("d6e-2")

  # Compares two die values from AllowedDice, useable for
  # +sort+ _if_ you use it with a block. i.e.:
  #
  #   [:d6, :d10, :d8].sort do |d1, d2|
  #     compare_dice(d1, d2)
  #   end
  #
  #   => [:d6, :d8, :d10]
  def compare_dice(die1, die2)
    idx1 = AllowedDiceOrder.index(die1)
    idx2 = AllowedDiceOrder.index(die2)

    # This handles values -not- in AllowedDice
    idx1 = -1 if idx1.nil?
    idx2 = -1 if idx2.nil?

    return idx1 <=> idx2
  end

  # Used to sort an array of dice.
  # NOTE: Values -not- in AllowedDice end up at the front
  # of the array.
  def sort_dice(dice=[])
    return [] if not dice.is_a?(Array)
    return dice.sort {|d1, d2| compare_dice(d1, d2) }
  end

end
