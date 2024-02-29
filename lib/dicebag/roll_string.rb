# This encapsulates the Roll class' string generation methods.
module RollString
  def to_s(no_spaces = false)
    @parts = []

    to_s_tree

    str = @parts.join ' '

    no_spaces ? str.tr(' ', '') : str
  end

  def inspect
    "<#{self.class.name} #{self}>"
  end

  private

  def to_s_tree
    tree.each do |op, value|
      @parts.push send("to_s_#{op}", value)
    end
  end

  def to_s_label(value)
    value.to_s
  end

  def to_s_start(value)
    value.to_s
  end

  def to_s_add(value)
    __op_value '+', value
  end

  def to_s_sub(value)
    __op_value '-', value
  end

  def to_s_mul(value)
    __op_value '*', value
  end

  def to_s_div(value)
    __op_value '/', value
  end

  def __op_value(oper, value)
    "#{oper}#{value}"
  end
end
