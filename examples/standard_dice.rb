require 'rubygems'
require 'dicebag'

module DiceBag
  module Standard

    class Die < Roll
      def initialize(sides)
        super("1d#{sides}")
      end
    end
    
    D4   = Die.new(4)
    D6   = Die.new(6)
    D8   = Die.new(8)
    D10  = Die.new(10)
    D12  = Die.new(12)
    D100 = Die.new(100)
  end
end
