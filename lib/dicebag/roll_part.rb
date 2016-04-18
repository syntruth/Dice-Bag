# Encoding: UTF-8

module DiceBag
  # This represents the xDx part of the dice string.
  class RollPart < SimplePart
    include RollPartString

    attr_reader :count
    attr_reader :sides
    attr_reader :parts
    attr_reader :options
    attr_reader :tally

    def initialize(part)
      @total  = nil
      @tally  = []
      @value  = part
      @count  = part[:count]
      @sides  = part[:sides]
      @notes  = part[:notes] || []

      # Our Default Options
      @options = { explode: 0, drop: 0, keep: 0, reroll: 0, target: 0 }

      @options.update(part[:options]) if part.key?(:options)
    end

    def notes
      @notes.empty? ? '' : @notes.join("\n")
    end

    # Checks to see if this instance has rolled yet
    # or not.
    def rolled?
      @total.nil? ? false : true
    end

    # Rolls a single die from the xDx string.
    def roll_die
      num = 0
      num = rand(sides) + 1 while num <= @options[:reroll]

      num
    end

    def roll
      generate_results

      @results.sort!
      @results.reverse!

      # Save the tally in case it's requested later.
      @tally = @results.dup

      # Drop the low end numbers if :drop is not zero.
      handle_drop

      # Keep the high end numbers if :keep is greater than zero.
      handle_keep

      # Set the total.
      handle_total

      self
    end

    # Gets the total of the last roll; if there is no
    # last roll, it calls roll() first.
    def total
      roll if @total.nil?

      @total
    end

    def <=>(other)
      total <=> other.total
    end

    private

    def generate_results
      @results = []

      count.times do
        r = roll_die

        @results.push(r)

        handle_explode(r) unless @options[:explode].zero?
      end
    end

    def handle_explode(r)
      while r >= @options[:explode]
        r = roll_die

        @results.push(r)
      end
    end

    def handle_drop
      return unless @options[:drop] > 0

      # Note that we invert the drop value here.
      range = 0...-(@options[:drop])

      @results = @results.slice range
    end

    def handle_keep
      return unless @options[:keep] > 0

      range = 0...@options[:keep]

      @results = @results.slice range
    end

    def handle_total
      # If we have a target number, count how many rolls
      # in the results are >= than this number, otherwise
      # we just add up all the numbers.
      @total = if @options[:target] && @options[:target] > 0
                 @results.count { |r| r >= @options[:target] }
               else
                 # I think reduce(:+) is ugly, but it's very fast.
                 @results.reduce(:+)
               end
    end
  end
end
