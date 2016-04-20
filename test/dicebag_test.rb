require 'minitest/autorun'

# :D
# This produces the following sequence of
# numbers for 1d6 rolls (which are what is
# used in all tests.)
# [1, 4, 6, 3, 5, 1, 1, 5, 4, 5, 3, 4, 4, 4, 1, 2, 3, 2, 6, 6]
def make_not_so_random!
  srand 1213
end

def xdx(dstr)
  DiceBag.parse dstr
end

require_relative '../lib/dicebag.rb'
require_relative './parser.rb'
require_relative './transform.rb'
require_relative './simple_part.rb'
require_relative './label_part.rb'
require_relative './static_part.rb'
require_relative './roll_part.rb'
require_relative './roll.rb'
require_relative './result.rb'
require_relative './roll_part_string.rb'
require_relative './roll_string.rb'
