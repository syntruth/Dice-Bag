# Encoding: UTF-8

module DiceBag
  # This class parses the dice string into the individual
  # components. To understand this code, please refer to
  # the Parslet library's documentation.
  class Parser < Parslet::Parser
    # Base rules.
    rule(:space?)  { str(' ').repeat }

    # Numbers are limited to 3 digit places. Why?
    # To prevent abuse from people rolling:
    # 999999999D999999999 and 'DOS'-ing the app.
    rule(:number)  { match('[0-9]').repeat(1, 3) }
    rule(:number?) { number.maybe }

    # Label rule
    # Labels must match '(<some text here>)' and
    # are not allowed to have commas in the label.
    # This for future use of parsing multiple dice
    # definitions in comma-separated strings.
    # The :label matches anything that ISN'T a
    # parenethesis or a comma.
    rule(:lparen) { str('(') }
    rule(:rparen) { str(')') }
    rule(:label) do
      lparen >> match('[^(),]').repeat(1).as(:label) >> rparen >> space?
    end

    # count and sides rules.
    # :count is allowed to be nil, which will default
    # to 1.
    rule(:count) { number?.as(:count) }
    rule(:sides) { match('[dD]') >> number.as(:sides) }

    # xDx Parts.
    # All xDx parts may be followed by none, one, or more
    # options.
    #
    # TODO: Remove the .as(:xdx) and rework the Transform
    # sub-class to account for it. It'll make the
    # resulting data much cleaner.
    rule(:xdx) { (count >> sides).as(:xdx) >> options? }

    # xdx Options.
    # Note that :explode is allowed to NOT have a number
    # assigned, which will leave it with a nil value. This
    # is handled in the Transform class.
    rule(:explode) { str('e') >> number?.as(:explode) >> space? }
    rule(:drop)    { str('d') >> number.as(:drop) >> space? }
    rule(:keep)    { str('k') >> number.as(:keep) >> space? }
    rule(:reroll)  { str('r') >> number.as(:reroll) >> space? }
    rule(:target)  { str('t') >> number.as(:target) >> space? }

    # This allows options to be defined in any order and
    # even have more than one of the same option, however
    # only the last option of a given key will be kept.
    rule(:option) do
      (drop | explode | keep | reroll | target)
    end

    rule(:options) { space? >> option.repeat >> space? }
    rule(:options?) { options.maybe.as(:options) }

    # Part Operators.
    rule(:add) { str('+') }
    rule(:sub) { str('-') }
    rule(:mul) { str('*') }
    rule(:div) { str('/') }
    rule(:op)  { (add | sub | mul | div).as(:op) }

    # Part Rule
    # A part is an operator, followed by either an xDx
    # string or a static number value.
    rule(:part) do
      space? >> op >> space? >> (xdx | number).as(:value) >> space?
    end

    # All parts of a dice roll MUST start with an xDx
    # string and then followed by any optional parts.
    # The first xDx string is labeled as :start.
    rule(:parts) { xdx.as(:start) >> part.repeat }

    # A dice string is an optional label, followed by
    # the defined parts.
    rule(:dice) { label.maybe >> parts }

    root(:dice)
  end
end
