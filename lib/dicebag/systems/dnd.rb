# This models a D20 roll used in various D&D versions for rolling a d20
# +/-mod to equal or exceed a DC value.
#
# This is a very simple version, but could easily be expanded on.
#
# Usage:
#
#     die = D20.new
#
#     die.roll 5, 15  => [:success, 17]
#     die.roll -3, 12 => [:fail, 9]
class D20
  attr_reader :mod
  attr_reader :dc

  def self.roll(mod = 0, difficulty = 10)
    new(mod, difficulty).roll
  end

  def initialize(mod = 0, difficulty = 10)
    @mod   = mod.to_i
    @dc    = difficulty.to_i
    @dstr  = "1d20 #{stringify_mod}"
    @roll  = DiceBag::Roll.new @dstr
  end

  def roll
    total = roll_for_result.total
    sym   = total >= dc ? :success : :failure

    [sym, total]
  end

  def stringify_mod
    return "+#{@mod}" if @mod.positive?

    return @mod.to_s  if @mod.negative?

    ''
  end

  def roll_for_result
    @roll.roll
  end
end

# Roll a d20 with Advantage
class D20Advantage < D20
  def roll_for_result
    r1 = @roll.roll
    r2 = @roll.roll

    [r1, r2].max
  end
end

# Roll a d20 with Disadvantage
class D20Disadvantage < D20
  def roll_for_result
    r1 = @roll.roll
    r2 = @roll.roll

    [r1, r2].min
  end
end
