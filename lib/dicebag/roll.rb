module DiceBag
  # This is the 'main' class of Dice Bag. This class
  # takes the dice string, parses it, and encapsulates
  # the actual rolling of the dice. If no dice string
  # is given, it defaults to DefaultRoll.
  class Roll
    attr :dstr
    attr :tree

    alias :parsed :tree

    def initialize(dstr=nil)
      @dstr   = dstr ||= DefaultRoll
      @tree   = DiceBag.parse(dstr)
      @result = nil
    end

    def notes
      s = ""

      self.tree.each do |op, part|
        if part.is_a?(RollPart)
          n  = part.notes
          s += "For: #{part}:\n#{n}\n\n" unless n.empty?
        end
      end

      return s
    end

    def result
      self.roll() unless @result
      return @result
    end

    def roll
      total    = 0
      label    = ""
      sections = []
    
      self.tree.each do |op, part|
        do_push = true
 
        # If this is a RollPart instance,
        # ensure fresh results.
        part.roll() if part.is_a?(RollPart)

        case op
        when :label
          label   = part.value()
          do_push = false
        when :start
          total = part.total()
        when :add
          total += part.total()
        when :sub
          total -= part.total()
        when :mul
          total *= part.total()
        when :div
          total /= part.total()
        end

        sections.push(part) if do_push
      end

      @result = Result.new(label, total, sections)

      return @result
    end

    def to_s(with_space=true)
      s = ""

      sp = with_space ? ' ' : ''

      self.tree.each do |op, value|
        case op
        when :label
          s += "#{value}#{sp}"
        when :start
          s += "#{value}#{sp}"
        when :add
          s += "+#{sp}#{value}#{sp}"
        when :sub
          s += "-#{sp}#{value}#{sp}"
        when :mul
          s += "*#{sp}#{value}#{sp}"
        when :div
          s += "/#{sp}#{value}#{sp}"
        end
      end

      return s.strip
    end
  end

end
