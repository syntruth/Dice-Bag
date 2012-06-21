module DiceBag
  # The subclass for a label.
  class LabelPart < SimplePart
    def to_s
      return "(%s)" % self.value
    end
  end

end
