module DiceBag
  # This is service class to calculate the Maximum/Minimum for the given
  # Roll.
  class MinMaxCalc
    attr_reader :roll
    attr_reader :method
    attr_reader :opposite

    def self.average(roll)
      (maximum(roll) + minimum(roll)) / 2.0
    end

    def self.maximum(roll)
      call roll, :maximum
    end

    def self.minimum(roll)
      call roll, :minimum
    end

    def self.call(roll, method)
      new(roll, method).perform
    end

    def initialize(roll, method)
      @roll     = roll
      @method   = method
      @opposite = opposite_method
      @total    = 0
    end

    def perform
      roll.tree.each do |op, part|
        next unless part.is_a?(RollPart) || part.is_a?(StaticPart)

        calculate op, part
      end

      @total
    end

    # Update the total based on the oper. For 'additive' operations, we
    # use the method, but if it's 'subtractive' then it uses the
    # opposite method.
    def calculate(oper, part)
      case oper
      when :start then @total  = part.send(method)
      when :add   then @total += part.send(method)
      when :sub   then @total -= part.send(opposite)
      when :mul   then @total *= part.send(method)
      when :div   then @total /= part.send(opposite)
      end
    end

    def opposite_method
      method == :maximum ? :minimum : :maximum
    end
  end
end
