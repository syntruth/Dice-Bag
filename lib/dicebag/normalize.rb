# DiceBag Module
module DiceBag
  # Encapsulate the Normalization Process
  #
  # This takes the parsed tree, AFTER it has been through the Transform
  # class, and massages the data a bit more, to ease the iteration that
  # happens in the Roll class. It will convert all values into the
  # correct *Part classes.
  class Normalize
    # The Abstract Source Tree
    attr_reader :ast

    def self.call(ast)
      new(ast).perform
    end

    def initialize(ast)
      # ASTs that only have a :start section will be a single array by
      # itself, with the first element being `:start`, so we need to
      # wrap it once more.
      ast = [ast] unless ast.first.is_a? Array

      @ast = ast
    end

    def perform
      ast.map { |part| normalize part }
    end

    private

    def normalize(part)
      [op(part.first), value(part.last)]
    end

    def op(oper)
      # We swap out the strings for symbols. If the oper is not one of
      # the arithimetic operators, then the oper itself is returned.
      # (This should only happen on :start and :label parts.)
      case oper
      when '+' then :add
      when '-' then :sub
      when '*' then :mul
      when '/' then :div
      else
        oper
      end
    end

    def value(val)
      case val
      when String
        LabelPart.new val
      when Hash
        RollPart.new normalize_xdx(val)
      when Integer
        StaticPart.new val
      else
        val
      end
    end

    # This further massages the xDx hashes.
    def normalize_xdx(hash)
      count = hash[:xdx][:count]
      sides = hash[:xdx][:sides]

      # Delete the no longer needed :xdx key.
      hash.delete(:xdx)

      # Default to at least 1 die.
      count = 1 if count.nil? || count.zero?

      # Set the :count and :sides keys directly and setup the notes array.
      hash[:count] = count
      hash[:sides] = sides
      hash[:notes] = []

      normalize_options hash
    end

    def normalize_options(hash)
      if hash[:options].empty?
        hash.delete(:options)

        return hash
      end

      normalize_explode hash
      normalize_reroll hash
      normalize_drop_keep hash
      normalize_target hash
      normalize_failure hash

      hash
    end

    # Prevent Explosion abuse.
    def normalize_explode(hash)
      return unless hash[:options].key?(:explode)

      explode = hash[:options][:explode]

      return if explode.nil? || explode >= 2

      hash[:options][:explode] = nil

      hash[:notes].push("Explode set to #{hash[:sides]}")
    end

    # Prevent Reroll abuse.
    def normalize_reroll(hash)
      return unless hash[:options].key?(:reroll) &&
                    hash[:options][:reroll] >= hash[:sides]

      hash[:options][:reroll] = 0

      hash[:notes].push 'Reroll reset to 0.'
    end

    # Make sure there are enough dice to handle both Drop and Keep values.
    # If not, both are reset to 0. Harsh.
    def normalize_drop_keep(hash)
      drop = hash[:options].fetch(:drop, 0)
      keep = hash[:options].fetch(:keep, 0)

      return unless (drop + keep) >= hash[:count]

      hash[:options][:drop] = 0
      hash[:options][:keep] = 0

      hash[:notes].push 'Drop and Keep Conflict. Both reset to 0.'
    end

    # If we have a failure number, make sure it is equal to or less than
    # the dice sides and greater than 0, otherwise, set it to 0 (i.e. no
    # failure number) and add a note.
    def normalize_failure(hash)
      return unless hash[:options].key?(:failure)

      failure = hash[:options][:failure]

      return if failure >= 0 && failure <= hash[:sides]

      hash[:options][:failure] = 0

      hash[:notes].push 'Failure number too large or is negative; reset to 0.'
    end

    # Finally, if we have a target number, make sure it is equal to or
    # less than the dice sides and greater than 0, otherwise, set it to 0
    # (i.e. no target number) and add a note.
    def normalize_target(hash)
      return unless hash[:options].key? :target

      target = hash[:options][:target]

      return if target >= 0 && target <= hash[:sides]

      hash[:options][:target] = 0

      hash[:notes].push 'Target number too large or is negative; reset to 0.'
    end
  end
end
