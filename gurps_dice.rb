require "dicelib"

module Dice

  class GurpsRoll < SimpleRoll

    def initialize
      super("3d6")
    end

    def roll(target, mod=0)
      mod = 0 if not mod.is_a?(Fixnum)

      crit_success = [3, 4]
      crit_failure = [18]

      total_target = target + mod

      crit_success += [5]  if total_target >= 15
      crit_success += [6]  if total_target >= 16
      crit_failure += [17] if total_target <= 15

      result = super().total()

      success = if crit_success.include?(result)
        :critical_success
      elsif crit_failure.include?(result)
        :critical_failure
      elsif result <= total_target
        :success
      else
        :failure
      end

      return [success, result]
    end

  # End class
  end

# End module
end
