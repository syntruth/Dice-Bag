require 'minitest/autorun'

# :D
#
# This produces the following sequence of numbers for 1d6 rolls, which
# is the dice used in all tests.
#
# [1, 4, 6, 3, 5, 1, 1, 5, 4, 5, 3, 4, 4, 4, 1, 2, 3, 2, 6, 6]
def make_not_so_random!
  srand 1213
end

def xdx(dstr)
  DiceBag.parse dstr
end

require_relative '../lib/dicebag'
require_relative 'parser'
require_relative 'transform'
require_relative 'normalize'
require_relative 'simple_part'
require_relative 'label_part'
require_relative 'static_part'
require_relative 'roll_part'
require_relative 'roll'
require_relative 'result'
require_relative 'roll_part_string'
require_relative 'roll_string'
