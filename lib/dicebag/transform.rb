# Encoding: UTF-8

# This continues definining the DiceBag module.
module DiceBag
  # This is the Transform subclass that takes the
  # parsed tree and transforms it into its (almost)
  # final form. (It gets a normalization pass later.)
  class Transform < Parslet::Transform
    def self.hashify_options(options)
      opts = {}

      options.each { |opt, val| opts[opt] = val } if options.is_a?(Array)

      opts
    end

    # Option transforms. These are turned into an array of
    # 2-element arrays ('tagged arrays'), which is then
    # hashified later. (There is no way to update the
    # options when these rules are matched.)
    rule(drop:    simple(:x)) { [:drop,   Integer(x)] }
    rule(keep:    simple(:x)) { [:keep,   Integer(x)] }
    rule(reroll:  simple(:x)) { [:reroll, Integer(x)] }
    rule(target:  simple(:x)) { [:target, Integer(x)] }

    # Explode is special, in that if it is nil, then it
    # must remain that way.
    rule(explode: simple(:x)) do
      [:explode, (x ? Integer(x) : nil)]
    end

    # Parts {:ops => (:xdx | :number)}
    # These are first-match, so the simple number will
    # be matched before the xdx subtree.

    # Match an operator followed by a static number.
    # TODO: find out why this is not matching simple
    # op => integers! -- 2016-04-18
    rule(op: simple(:o), value: simple(:v)) do
      [String(o), Integer(v)]
    end

    # Match an operator followed by an :xdx subtree.
    rule(op: simple(:o), value: subtree(:part)) do
      value = if part.is_a? Hash
                count   = Integer(part[:xdx][:count])
                sides   = Integer(part[:xdx][:sides])
                options = Transform.hashify_options(part[:options])

                { xdx: { count: count, sides: sides }, options: options }
              else
                Integer(part)
              end

      [String(o), value]
    end

    # Match a label by itself.
    rule(label: simple(:s)) { { label: String(s) } }

    # Match a label followed by a :start subtree.
    rule(label: simple(:s), start: subtree(:part)) do
      label   = String(s)
      xdx     = part[:xdx]
      options = Transform.hashify_options(part[:options])

      [{ label: label }, { start: { xdx: xdx, options: options } }]
    end

    # Match a :start subtree, with the label not present.
    # Note that this returns a hash, but the final output
    # will still be in an array.
    rule(start: subtree(:part)) do
      {
        start: {
          xdx:     part[:xdx],
          options: Transform.hashify_options(part[:options])
        }
      }
    end

    # Convert the count and sides of an :xdx part.
    rule(count: simple(:c), sides: simple(:s)) do
      { count: Integer(c), sides: Integer(s) }
    end
  end
end
