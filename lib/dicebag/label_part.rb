module DiceBag
  # The subclass for a label.
  class LabelPart < SimplePart
    def to_s
      format('(%s)', value)
    end

    def inspect
      "<#{self.class.name} #{self}>"
    end
  end
end
