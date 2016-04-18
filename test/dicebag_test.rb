require 'minitest/autorun'

# :D
def make_not_so_random!
  srand 1213
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
