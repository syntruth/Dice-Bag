# Encoding: UTF-8

# This encapsulates the RollPart string
# generation methods.
module RollPartString
  # This takes the @parts hash and recreates the xDx
  # string. Optionally, passing true to the method will
  # remove spaces form the finished string.
  def to_s(no_spaces = false)
    @string = ''
    @space  = (no_spaces ? '' : ' ')

    to_s_xdx
    to_s_explode
    to_s_drop
    to_s_keep
    to_s_reroll
    to_s_target

    @string
  end

  private

  def to_s_xdx
    c = count.zero? ? '' : count.to_s
    s = sides.to_s

    @string += format('%sd%s', c, s)
  end

  def to_s_explode
    return unless @options[:explode].zero?

    e = (@options[:explode] == sides) ? @options[:explode] : ''

    @string += format('%se%s', @space, e)
  end

  def to_s_drop
    return unless @options[:drop].zero?

    @string += format('%sd%d', @space, @options[:drop])
  end

  def to_s_keep
    return unless @options[:keep].zero?

    @string += format('%sk%s', @space, @options[:keep])
  end

  def to_s_reroll
    return unless @options[:reroll].zero?

    @string += format('%sr%s', @space, @options[:reroll])
  end

  def to_s_target
    return unless @options[:target].zero?

    @string += format('%st%s', @space, @options[:target])
  end
end
