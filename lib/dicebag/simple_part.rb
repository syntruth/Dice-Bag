module DiceBag
  # The most simplest of a part. If a given part of
  # a dice string is not a Label, Fixnum, or a xDx part
  # it will be an instance of this class, which simply
  # returns the value given to it.
  class SimplePart
    attr :value

    def initialize(part)
      @value = part
    end

    def result
      return @value
    end

    def to_s
      return @value
    end
  end
end
