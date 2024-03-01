# DiceBag module.
module DiceBag
  # This is the Transform subclass that takes the parsed tree and
  # transforms it into its (almost) final form. (It gets a normalization
  # pass later.)
  class Transform < Parslet::Transform
    def self.hashify_options(options)
      return options if options.is_a? Hash

      opts = {}

      options.each { |val| opts.update val } if options.respond_to?(:each)

      opts
    end

    # Options.
    #
    # The full options hash is updated later with these sub-hashes.
    rule(drop: simple(:x)) do
      { drop: Integer(x) }
    end

    rule(keep: simple(:x)) do
      { keep: Integer(x) }
    end

    rule(keeplowest: simple(:x)) do
      { keeplowest: Integer(x) }
    end

    rule(reroll: simple(:x)) do
      { reroll: Integer(x) }
    end

    rule(target: simple(:x)) do
      { target: Integer(x) }
    end

    rule(failure: simple(:x)) do
      { failure: Integer(x) }
    end

    # Explode is special, in that if it is nil, then we set it to -1 to
    # reflect that, and it'll be updated in the normalization phase.
    rule(explode: simple(:x)) do
      { explode: (x ? Integer(x) : -1) }
    end

    # Match a label by itself.
    rule(label: simple(:s)) { [:label, LabelPart.new(String(s))] }

    # Match a label followed by a :start subtree.
    rule(label: simple(:s), start: subtree(:part)) do
      [
        [:label, LabelPart.new(String(s))],
        [:start, part]
      ]
    end

    # Match a :start subtree, with the label not present.
    rule(start: subtree(:part)) do
      [:start, part]
    end

    # Match the xdx and options hash.
    #
    # TODO: Remove the .as(:xdx) in the Parser sub-class and then update
    # this class to account for it. It'll make the resulting data much
    # cleaner.
    rule(xdx: subtree(:xdx), options: subtree(:opts)) do
      { xdx: xdx, options: Transform.hashify_options(opts) }
    end

    # Convert the count and sides of an :xdx part.
    rule(count: simple(:c), sides: simple(:s)) do
      {
        count: (c ? Integer(c) : 1),
        sides: Integer(s)
      }
    end

    # Match an operator followed by an :xdx subtree.
    rule(op: simple(:o), value: subtree(:part)) do
      part[:options] = Transform.hashify_options(part[:options])

      [String(o), part]
    end

    # Match an operator followed by a immediate value.
    rule(op: simple(:o), value: simple(:v)) do
      [String(o), Integer(v)]
    end
  end
end
