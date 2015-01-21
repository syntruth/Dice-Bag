module DiceBag
  # The most simplest of a part. If a given part of
  # a dice string is not a Label, Fixnum, or a xDx part
  # it will be an instance of this class, which simply
  # returns the value given to it.
  class SimplePart
    attr_reader :value

    def initialize(part)
      @value = part
    end

    def result
      value
    end

    def to_s
      value
    end
  end
end
