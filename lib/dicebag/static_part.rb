module DiceBag
  # This represents a static, non-random number part
  # of the dice string.
  class StaticPart < SimplePart
    def initialize(num)
      num    = num.to_i() if num.is_a?(String)
      @value = num
    end

    def total
      return self.value
    end

    def to_s
      return self.value.to_s()
    end
  end

end
