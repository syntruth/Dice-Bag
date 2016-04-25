# Encoding: UTF-8

# This models a D20 roll used in various
# D&D versions for rolling a d20 +/-mod to
# equal or exceed a DC value.
#
# This is a very simple version, but could
# easily be expanded on.
#
# Usage:
#
#     die = D20.new
#
#     die.roll 5, 15  => [:success, 17]
#     die.roll -3, 12 => [:fail, 9]
class D20
  def initialize(mod = 0, dc = 10)
    update mod, dc
  end

  def roll(mod = 0, dc = 10)
    update mod, dc

    result = @roll.result

    sym = result.total >= @dc ? :success : :failure

    [sym, result.total]
  end

  def update(mod, dc)
    @mod   = mod.to_i
    @dc    = dc.to_i
    @dstr  = "1d20 #{stringify_mod}"
    @roll  = DiceBag::Roll.new @dstr
  end

  def stringify_mod
    return "+#{@mod}" if @mod > 0
    return @mod.to_s  if @mod < 0

    ''
  end
end
