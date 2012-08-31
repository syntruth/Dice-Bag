module DiceBag
  # This represents the xDx part of the dice string.
  class RollPart < SimplePart

    attr :count
    attr :sides
    attr :parts
    attr :options

    def initialize(part)
      @total  = nil
      @tally  = []
      @value  = part
      @count  = part[:count]
      @sides  = part[:sides]
      @notes  = part[:notes] || []

      # Our Default Options
      @options = {
        :explode => 0,
        :drop    => 0,
        :keep    => 0,
        :reroll  => 0,
        :target  => 0
      }

      @options.update(part[:options]) if part.has_key?(:options)
    end

    def notes
      return @notes.join("\n") unless @notes.empty?
      return ""
    end

    # Checks to see if this instance has rolled yet
    # or not.
    def has_rolled?
      return @total.nil? ? false : true
    end

    # Rolls a single die from the xDx string.
    def roll_die()
      num    = 0
      reroll = @options[:reroll]

      while num <= reroll
        num = rand(self.sides) + 1
      end

      return num
    end

    def roll
      results = []
      explode = @options[:explode]

      self.count.times do
        roll = self.roll_die()

        results.push(roll)

        unless explode.zero?
          while roll >= explode
            roll = self.roll_die()
            results.push(roll)
          end
        end
      end

      results.sort!
      results.reverse!

      # Save the tally in case it's requested later.
      @tally = results.dup()

      # Drop the low end numbers if :drop is less than zero.
      if @options[:drop] < 0
        results = results[0 ... @options[:drop]]
      end

      # Keep the high end numbers if :keep is greater than zero.
      if @options[:keep] > 0
        results = results[0 ... @options[:keep]]
      end

      # If we have a target number, count how many rolls
      # in the tally are >= than this number, otherwise
      # we just add up all the numbers.
      if @options[:target] and @options[:target] > 0
        @total = results.count {|r| r >= @options[:target]}
      else
        # I think reduce(:+) is ugly, but it's very fast.
        @total = results.reduce(:+)
      end

      return self
    end

    # Returns the tally from the roll. This is the entire
    # tally, even if a :keep or :drop options were given.
    def tally()
      return @tally
    end

    # Gets the total of the last roll; if there is no 
    # last roll, it calls roll() first.
    def total
      self.roll() if @total.nil?
      return @total
    end

    # This takes the @parts hash and recreates the xDx
    # string. Optionally, passing true to the method will
    # remove spaces form the finished string.
    def to_s(no_spaces=false)
      s = ""

      sp = no_spaces ? "" : " "
      
      s += self.count.to_s unless self.count.zero?
      s += "d"
      s += self.sides.to_s

      unless @options[:explode].zero?
        s += "#{sp}e"
        s += @options[:explode].to_s unless @options[:explode] == self.sides
      end

      s += "#{sp}t" + @options[:target].to_s   unless @options[:target].zero?
      s += "#{sp}~" + @options[:drop].abs.to_s unless @options[:drop].zero?
      s += "#{sp}!" + @options[:keep].to_s     unless @options[:keep].zero?
      s += "#{sp}r" + @options[:reroll].to_s   unless @options[:reroll].zero?

      return s
    end

    def <=>(other)
      return self.total <=> other.total
    end
  end

end
