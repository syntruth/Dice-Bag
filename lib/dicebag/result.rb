module DiceBag
  # This class merely encapsulates the result,
  # providing convience methods to access the
  # results of each section if desired.
  class Result 
    attr_reader :label
    attr_reader :total
    attr_reader :sections

    def initialize(label, total, sections)
      @label    = label
      @total    = total
      @sections = sections
    end

    def each(&block)
      self.sections.each do |section|
        yield section
      end
      return nil
    end

    def to_s
      return "#{self.label}: #{self.total}" unless self.label.empty?
      return self.total.to_s
    end
  end

end
