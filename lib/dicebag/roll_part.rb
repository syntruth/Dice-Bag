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
    attr_reader :reroll_count

    def initialize(part)
      @total            = nil
      @tally            = []
      @value            = part
      @count            = part[:count]
      @sides            = part[:sides]
      @notes            = part[:notes] || []
      @exploding_series = []
      @reroll_count = 0

      # Our Default Options
      
      @options = { explode: 0, explode_indefinite: 0, drop: 0, keep: 0, keeplowest: 0, reroll: 0, reroll_indefinite: 0, target: 0, failure: 0, botch: 0 }

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
      num = rand(sides) + 1

      # Single Reroll
      if num <= @options[:reroll] or num <= @options[:reroll_indefinite]
        num = rand(sides) + 1
        @reroll_count += 1
      end

      # Indefinite rerolls
      for i in 0..99 # limited to 100 rerolls per dice
        if num > @options[:reroll_indefinite]
          break
        end
        num = rand(sides) + 1
        @reroll_count += 1
      end

      num
    end

    def roll
      generate_results

      if @options[:keeplowest] >= 1
        @tally = @results.dup
        @tally.sort!
        @tally.reverse!
        @results.sort!
        @results.reverse!
        handle_drop
        @results.reverse!
        handle_keeplowest
        handle_total
        handle_explode_tally
        return
      end

      @results.sort!

      @results.reverse!

      # Save the tally in case it's requested later.
      @tally = @results.dup

      # Drop the low end numbers if :drop is not zero.
      handle_drop

      # Keep the high end numbers if :keep is greater than zero.
      handle_keep

      handle_botch

      # Set the total.
      handle_total

      # Make the tally look good with explosions
      handle_explode_tally

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

        handle_explode(r)
      end
    end

    def handle_explode(r)

      series_num = 0
      if (r >= @options[:explode] and @options[:explode] != 0) or ( r >= @options[:explode_indefinite] and @options[:explode_indefinite] != 0)
        r = roll_die

        @results.push(r)
        if @exploding_series.length < 1
          @exploding_series.append([])
        end
        @exploding_series[series_num].push(r)
      end

      if options[:explode_indefinite] == 0
        return # No further processing needed
      end

      while r >= @options[:explode_indefinite]
        series_num += 1
        r = roll_die

        @results.push(r)
        if @exploding_series.length < series_num + 1
          @exploding_series.append([])
        end
        @exploding_series[series_num].push(r)

        if series_num >= 100
          break
        end
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

    def handle_keeplowest

      return unless @options[:keeplowest] > 0
      range = 0...@options[:keeplowest]

      @results = @results.slice range
    end

    def handle_botch
      return unless @options[:botch] > 0
      range = 0...@options[:botch]

      @results = @results.slice range
    end

    def handle_total
      # If we have a target number, count how many rolls
      # in the results are >= than this number and subtract
      # the number <= the failure threshold, otherwise
      # we just add up all the numbers.
      @total = if (@options[:target] || @options[:failure]) && ( @options[:target] > 0 || @options[:failure] > 0 )
                 if @options[:target] && @options[:target] > 0
                   @results.count {|r| r >= @options[:target] } - @results.count { |r| r <= @options[:failure] }
                 else
                   0 - @results.count { |r| r <= @options[:failure] }
                 end 
               else
                 # I think reduce(:+) is ugly, but it's very fast.
                 @results.reduce(:+)
               end
    end

    # Formats the tally to look like with explodes
    def handle_explode_tally

      # If we have any explosions
      if @exploding_series.length > 0
        temp_tally = @tally
        @tally = []
        @tally.append(temp_tally)
        for series in @exploding_series
          for entry in series
            tally[0].delete_at(tally[0].index(entry))
          end

          tally.append( series.sort.reverse ) #Put unsort options in here in the future
        end
      end
    end
  end
end
