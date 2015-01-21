# Encoding: UTF-8

module DiceBag
  # The subclass for a label.
  class LabelPart < SimplePart
    def to_s
      format('(%s)', value)
    end
  end
end
