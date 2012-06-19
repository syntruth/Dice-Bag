require 'rubygems'
require 'parslet'

module Dice
  class Parser < Parslet::Parser

    # Base rules.
    rule(:space?)  { str(' ').repeat }
    rule(:number)  { match('[0-9]').repeat(1) }
    rule(:number?) { number.maybe }

    # count and sides rules.
    rule(:count) { number?.as(:count) }
    rule(:sides) { match('[dD]') >> number.as(:sides) }

    # Roll Options.
    rule(:explode) { str('e') >> number?.as(:explode) }
    rule(:drop)    { str('~') >> number.as(:drop) }
    rule(:keep)    { str('!') >> number.as(:keep) }
    rule(:reroll)  { str('r') >> number.as(:reroll) }

    rule(:options) { 
      space? >> (drop | explode | keep | reroll).repeat >> space?
    }

    rule(:options?) { options.maybe.as(:options) }

    # Static modifiers.
    rule(:add) { str('+') }
    rule(:sub) { str('-') }
    rule(:mul) { str('*') }
    rule(:div) { str('/') }

    rule(:op)   { (add | sub | mul | div).as(:op) }
    rule(:mod)  { space? >> op >> space? >> number.as(:mod) >> space? }
    rule(:mods) { mod.repeat.as(:mods) }

    rule(:dice) { (count >> sides).as(:xdx) >> options? >> mods }

    root(:dice)
  end

  class Transform < Parslet::Transform

    rule(:count => simple(:x)) { Integer(x) }
    rule(:sides => simple(:x)) { Integer(x) }

    rule(:explode => simple(:x)) { [:explode, Integer(x)] }
    rule(:drop    => simple(:x)) { [:drop,    Integer(x)] }
    rule(:keep    => simple(:x)) { [:keep,    Integer(x)] }
    rule(:reroll  => simple(:x)) { [:reroll,  Integer(x)] }

    rule(:mod => simple(:m), :op => simple(:o)) do
      op = case o
      when '+' then :add
      when '-' then :sub
      when '*' then :mul
      when '/' then :div
      else :unknown
      end

      [op, Integer(m)]
    end

    rule(:count => simple(:c), :sides => simple(:s)) do
      {
        :count => Integer(c),
        :sides => Integer(s)
      }
    end

  end

  def self.normalize_tree(tree)
    tree[:count] = tree[:xdx][:count]
    tree[:sides] = tree[:xdx][:sides]

    tree.delete(:xdx)

    return tree
  end
end 

if $0 == __FILE__
  require 'pp'

  dstrs = [
    # Basic rolls.
    '2d10', '1D20', 'd8',
    '1d20 +5', '2d4+2-1',
    
    # Complex ones!
    '5d6!3e + 4 - 1', 
    '6d12~2e10 +5 + 3'
  ]

  dstrs.each do |dstr|
    puts "Trying #{dstr}"

    tree = Dice::Parser.new.parse(dstr)
    ast  = Dice::Transform.new.apply(tree)
    
    pp Dice.normalize_tree(ast)
    puts ""
  end
end

