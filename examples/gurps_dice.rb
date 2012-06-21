require 'rubygems'
require 'dicebag'

class GURPSDice < DiceBag::Roll
  def initialize
    super('3d6')
  end

  def roll(target, mod=0)
    mod = 0 unless mod.is_a?(Fixnum)

    total_target = target + mod

    crit_success = [3, 4]
    crit_failure = [18]

    crit_success.push(5)  if total_target >= 15
    crit_success.push(6)  if total_target >= 16
    crit_failure.push(17) if total_target <= 15

    result = super()
    total  = result.total()

    success = if crit_success.include?(total)
      :critical_success
    elsif crit_failure.include?(total)
      :critical_failure
    elsif total <= total_target
      :success
    else
      :failure
    end

    return [success, total]
  end
end
