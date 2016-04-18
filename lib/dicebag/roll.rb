# Encoding: UTF-8

module DiceBag
  # This is the 'main' class of Dice Bag. This class
  # takes the dice string, parses it, and encapsulates
  # the actual rolling of the dice. If no dice string
  # is given, it defaults to DefaultRoll.
  class Roll
    include RollString

    attr_reader :dstr
    attr_reader :tree

    alias parsed tree

    def initialize(dstr = nil)
      @dstr   = dstr ||= DEFAULT_ROLL
      @tree   = DiceBag.parse dstr
      @result = nil
    end

    def notes
      str = ''

      tree.each do |_op, part|
        next unless part.is_a?(RollPart) || !part.notes.empty?

        str += format('For: %s\n%s\n\n', part, part.notes)
      end

      str
    end

    def result
      roll unless @result

      @result
    end

    def roll
      @label    = ''
      @total    = 0
      @sections = []

      handle_tree

      @result = Result.new(@label, @total, @sections)
    end

    private

    def handle_tree
      tree.each do |op, part|
        if op == :label
          @label = part.value
          next
        end

        part.roll if part.is_a?(RollPart) # ensure fresh results.

        handle_op op, part
      end
    end

    def handle_op(op, part)
      case op
      when :start then @total  = part.total
      when :add   then @total += part.total
      when :sub   then @total -= part.total
      when :mul   then @total *= part.total
      when :div   then @total /= part.total
      end

      @sections.push part
    end
  end
end
