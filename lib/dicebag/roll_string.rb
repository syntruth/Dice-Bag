# Encoding: UTF-8

# This encapsulates the Roll class' string
# generation methods.
module RollString
  def to_s(no_spaces = false)
    @string = ''
    @space  = no_spaces ? '' : ' '

    to_s_tree

    @string.strip
  end

  private

  def to_s_tree
    tree.each { |op, value| @string += send("to_s_#{op}", value) }
  end

  def to_s_label(value)
    "#{value}#{@space}"
  end

  def to_s_start(value)
    "#{value}#{@space}"
  end

  def to_s_add(value)
    "+#{@space}#{value}#{@space}"
  end

  def to_s_sub(value)
    "-#{@space}#{value}#{@space}"
  end

  def to_s_mul(value)
    "*#{@space}#{value}#{@space}"
  end

  def to_s_div(value)
    "/#{@space}#{value}#{@space}"
  end
end
