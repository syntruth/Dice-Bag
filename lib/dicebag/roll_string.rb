# Encoding: UTF-8

# This encapsulates the Roll class' string
# generation methods.
module RollString
  def to_s(no_spaces = false)
    @parts = []

    to_s_tree

    str = @parts.join ' '

    no_spaces ? str.tr(' ', '') : str
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
    _op_value '+', value
  end

  def to_s_sub(value)
    _op_value '-', value
  end

  def to_s_mul(value)
    _op_value '*', value
  end

  def to_s_div(value)
    _op_value '/', value
  end

  def _op_value(op, value)
    "#{op}#{value}"
  end
end
