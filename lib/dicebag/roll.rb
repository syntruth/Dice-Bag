module DiceBag
  # This is the 'main' class of Dice Bag. This class takes the dice
  # string, parses it, and encapsulates the actual rolling of the dice.
  # If no dice string is given, it defaults to DiceBag.default_roll
  class Roll
    include RollString

    attr_reader :dstr
    attr_reader :tree

    alias parsed tree

    def initialize(dstr = nil)
      @dstr   = dstr ||= DiceBag.default_roll
      @tree   = DiceBag.parse dstr
      @result = nil
    end

    def notes
      arr = []
      fmt = "For %s: %s\n"

      tree.each_value do |part|
        next unless part.is_a?(RollPart) && !part.notes.empty?

        arr.push format(fmt, part, part.notes)
      end

      arr
    end

    def notes_to_s
      n = notes

      n.empty? ? '' : n.join("\n")
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

    def average
      MinMaxCalc.average self
    end

    def maximum
      MinMaxCalc.maximum self
    end

    def minimum
      MinMaxCalc.minimum self
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

    def handle_op(oper, part)
      case oper
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
