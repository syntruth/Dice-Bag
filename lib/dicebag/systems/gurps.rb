require 'dicebag'

# This models the standard GURPS 3d6 dice pool used for attribute/skill
# tests.
#
# This will return an array of [status, result] where:
# - status is one of:
#   :success, :failure, :critical_success, or :critical_failure
# - result is the actual dice roll total.
class GURPS < DiceBag::Roll
  def self.roll(target, mod = 0)
    new.roll(target, mod)
  end

  def initialize
    super('3d6')
  end

  def roll(target, mod = 0)
    mod = 0 unless mod.is_a?(Integer)

    @total_target = target + mod
    @total        = super().total

    figure_success
    figure_failure

    [figure_result, @total]
  end

  private

  def figure_success
    @crit_success = [3, 4]

    @crit_success.push(5) if @total_target >= 15
    @crit_success.push(6) if @total_target >= 16
  end

  def figure_failure
    @crit_failure = [18]

    @crit_failure.push(17) if @total_target <= 15
  end

  def figure_result
    return :critical_success if @crit_success.include?(@total)
    return :critical_failure if @crit_failure.include?(@total)

    @total <= @total_target ? :success : :failure
  end
end
