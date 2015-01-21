# Encoding: UTF-8

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

    def each
      sections.each { |section| yield section }
    end

    def to_s
      return "#{label}: #{total}" unless label.empty?

      total.to_s
    end
  end
end
