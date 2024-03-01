# DiceBag Module
module DiceBag
  # This represents the xDx part of the dice string.
  class RollPart < SimplePart
    include RollPartString

    attr_reader :count
    attr_reader :sides
    attr_reader :parts
    attr_reader :options
    attr_reader :tally
    attr_reader :reroll_count

    def initialize(part)
      super part

      @total   = nil
      @tally   = []
      @count   = part[:count]
      @sides   = part[:sides]
      @notes   = part[:notes]
      @options = default_options

      @options.update(part[:options]) if part.key?(:options)
    end

    # Our Default Options
    #
    # Note the absence of :explode, that is handled below.
    def default_options
      {
        drop:       0,
        keep:       0,
        keeplowest: 0,
        reroll:     0,
        target:     0,
        failure:    0
      }
    end

    def notes
      @notes.empty? ? '' : @notes.join("\n")
    end

    # Checks to see if this instance has rolled yet or not.
    def rolled?
      @total.nil? ? false : true
    end

    def roll
      generate_results

      return __roll_for_keep_lowest if @options[:keeplowest].positive?

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
    end

    def __roll_for_keep_lowest
      @tally = @results.dup

      @tally.sort!
      @tally.reverse!
      @results.sort!

      handle_keeplowest
      handle_total
    end

    # Gets the total of the last roll; if there is no last roll, it
    # calls roll() first.
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

      explode = @options[:explode]

      count.times do
        roll = roll_die

        @results.push(roll)

        handle_explode(roll) unless explode.nil?
      end
    end

    # Rolls a single die from the xDx string.
    def roll_die
      num = __roll_die

      # Handle Reroll
      if options[:reroll].positive?
        num = __roll_die while num <= @options[:reroll]
      end

      num
    end

    def handle_explode(roll)
      # If the explode value is nil (allowed!) then default to the
      # number of sides.
      val = @options[:explode] || sides

      while roll >= val
        roll = roll_die

        @results.push(roll)
      end
    end

    def handle_drop
      return unless @options[:drop].positive?

      # Note that we invert the drop value here.
      range = 0...-(@options[:drop])

      @results = @results.slice range
    end

    def handle_keep
      return unless @options[:keep].positive?

      range = 0...@options[:keep]

      @results = @results.slice range
    end

    def handle_keeplowest
      return unless @options[:keeplowest].positive?

      range = 0...@options[:keeplowest]

      @results = @results.slice range
    end

    # If we have a target number, count how many rolls in the results
    # are >= than this number and subtract the number <= the failure
    # threshold, otherwise we just add up all the numbers.
    def handle_total
      tpos = @options[:target].positive?
      fpos = @options[:failure].positive?

      # Just add up the results.
      return __simple_total unless tpos || fpos

      # Add up successes and subtract failures.
      return __target_and_failure_total if tpos

      # Just tally failures.
      @total = 0 - __failure_total
    end

    def __roll_die
      rand(sides) + 1
    end

    def __simple_total
      # I think reduce(:+) is ugly, but it's very fast.
      @total = @results.reduce(:+)
    end

    def __target_and_failure_total
      tcount = __target_total
      fcount = __failure_total

      @total = tcount - fcount
    end

    def __target_total
      @results.count { |r| r >= @options[:target] }
    end

    def __failure_total
      @results.count { |r| r <= @options[:failure] }
    end
  end
end
