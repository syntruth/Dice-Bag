# DiceBag module
module DiceBag
  # This represents a static, non-random number part of the dice string.
  class StaticPart < SimplePart
    def initialize(num)
      num = num.to_i if num.is_a?(String)

      super(num)
    end

    def total
      value
    end

    # These are all just the same for this part.
    alias average total
    alias maximum total
    alias minimum total

    def to_s
      value.to_s
    end

    def inspect
      "<#{self.class.name} #{self}>"
    end
  end
end
