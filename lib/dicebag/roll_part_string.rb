# Encoding: UTF-8

# This encapsulates the RollPart string
# generation methods.
module RollPartString
  # This takes the @parts hash and recreates the xDx
  # string. Optionally, passing true to the method will
  # remove spaces form the finished string.
  def to_s(no_spaces = false)
    @parts = []

    to_s_xdx
    to_s_explode
    to_s_explode_indefinite
    to_s_drop
    to_s_keep
    to_s_keeplowest
    to_s_reroll
    to_s_reroll_indefinite
    to_s_target
    to_s_failure

    join_str = no_spaces ? '' : ' '

    @parts.join join_str
  end

  private

  def to_s_xdx
    c = count.zero? ? '' : count.to_s
    s = sides.to_s

    @parts.push format('%sd%s', c, s)
  end

  def to_s_explode
    return if @options[:explode].zero?

    e = (@options[:explode] == sides) ? @options[:explode] : ''

    @parts.push format('e%s', e)
  end

  def to_s_explode_indefinite
    return if @options[:explode_indefinite].zero?

    e = (@options[:explode_indefinite] == sides) ? @options[:explode_indefinite] : ''

    @parts.push format('ie%s', e)
  end

  def to_s_drop
    return if @options[:drop].zero?

    @parts.push format('d%d', @options[:drop])
  end

  def to_s_keep
    return if @options[:keep].zero?

    @parts.push format('k%s', @options[:keep])
  end

  def to_s_keeplowest
    return if @options[:keeplowest].zero?

    @parts.push format('kl%s', @options[:keeplowest])
  end

  def to_s_reroll
    return if @options[:reroll].zero?

    @parts.push format('r%s', @options[:reroll])
  end

  def to_s_reroll_indefinite
    return if @options[:reroll_indefinite].zero?

    @parts.push format('ir%s', @options[:reroll_indefinite])
  end

  def to_s_target
    return if @options[:target].zero?

    @parts.push format('t%s', @options[:target])
  end

  def to_s_failure
    return if @options[:failure].zero?

    @parts.push format('f%s', @options[:failure])
  end
end
