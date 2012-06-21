Ruby Dice Lib
=============

**Name   :** Dice Library for Ruby

**Author :** Randy Carnahan

**Version:** 3.0

**License:** LGPL OR MIT

**THIS IS OUTDATED NOW. UPDATE IN THE WORKS!**

The dice library for Ruby is an attempt to bring a standard interface
to every gamer's (RPG and otherwise) need to have dice rolled. The 
centralized concept to this is taking a standard formatted string and
parsing it, returning values from that string.

The original version of this library was the 'rolldice' Unix
command-line application. Since this, it's been added to to allow
additional elements in the dice string.

Note: prior versions of this library allowed for dice strings to be
"complex" in that there was more than one dice string, separated by
commas, to be parsed and returned. This feature was never really used,
so it's been removed to keep this newer version (3.0+) cleaner.

Starting with Version 3.0, this library now uses parslet, the excellent
Ruby syntax parser. It's made the internals a *bit* more complicated,
but has allowed greater flexibility in constructing dice strings. For 
example, previous version, you had to do '4d6 e6 !3' if you wanted the
dice to explode (see below) and to keep the 3 highest rolls. Now, the
e6 and !3 (and the other options) can be in any order after the xDx
part of the string.

Dice Strings
------------

**Simple Dice String**

A simple dice string, also called the xDx string, that represents a
single group of dice, such as 3d10 or 4d6. Optional parts of the 
Simple Dice string are given below.

A dice string is made up of one or more parts that consist of either:

- an optional label, which must be the first part of the string.
  Labels are defined within parenthesis.
- an xDx (such as 3d6) definition and options for that definition.
- a static modifier that is applied to the current total.

The allowed static modifiers are add (+), subtract (-), multiply (\*),
and divide (/). As the library (in the Roll class) enumerates over the
parsed tree, a total for that roll is kept; the static modifiers are 
applied *in the order they are gotten*, which is to say, the standard
order of arithmetic calculations do not apply. 

For example:

    2d6 + 5 * 3 - 6

...would roll the 2d6 for the total, then add 5 to it, then multiply
that total by 3, and finally subtract 6. The 5 is not multiplied by 3
for a 15 and then added to the roll result. Just something to keep in
mind.

Simple Dice String Options
--------------------------

In the following section, note that # is used to denote the number
part of a option.

**xDx** - denotes how many dice to roll and how many sides the dice
should have. This is the standard RPG dice syntax. Note that if the 
sides of the die is given as '%' it will be converted to 100 
automatically. This *must* come before any options for a given set of
dice.

**e#** - the explode value. Some game systems call this 'open ended'
dice. If the number rolled is greater than or equal to the value given
for this option, the die is rolled again and added to the total. If no
number is given for this option, it is assumed to be the same as the
number of sides on the die. Thus, '1d6e' is the same as '1d6e6'.

**~#** - this denotes how many dice to drop from the tally. These dice
are dropped *before* any dice are kept with !# below. So, '5d6 ~2' 
means roll five 6-sided dice and drop the lowest 2 values.

**!#** - this denotes how many dice to keep out of the number of dice
rolled, keeping the highest values from the roll. Thus, '4d6 !3' means
to roll four 6-sided dice and keep the best 3 values.

**r#** - this denotes a reroll value. If the die rolls this value or 
less, then the die is rolled again. Thus, '1d6r3' will only return a 
result of 4, 5, or 6. If the given value is larger than the number of
sides on the die, then it defaults to the sides - 1.

Dice String Limitations
-----------------------

Within the dice library itself, simple (xDx) strings are limited to 2
digits for all parts of the string except for the sides of the given
die, which can be up to 3 digits.

Using the Dice Library
----------------------

**TODO:** Update this section!

Using the library is rather straight forward:

    require 'dicelib'

    dice = Dice::Roll.new("(Damage) 2d8 + 5 + 1d6")

    results = dice.result()

    results.each do |result|
      puts "%10s: %s" % [result.label, result.total]
    end

This would output something like the following:

    Damage: 15

It is possible to get the individual sections values as well:

    results.each do |result|
      result.sections.each do |section|
        puts "%-4s: %s" % [section.to_s(), section.result()]
      end
    end

For the above given dice string, would print something like this:

    2d8: 7
      5: 5
    1d6: 3

Also, if you are curious to see how the dice string was parsed, you can 
retrieved the parsed value from the Roll instance using the tree() method:

    parsed = roll.tree()

For the above given dice string, this returns a nested array of values:

    Put tree ouput here!

Typically, you won't have to deal with the internals of a dice roll if all
you want are the results. However, you can dig down into the returned
result's classes to obtain pretty much any data you want.

For example, if you wanted to know the actual dice tally of a '4d6 !3' roll,
you could do this, after getting the result from Dice::Roll.result():

    result = Dice::Roll.new("4d6 !3").result()

    tally = result[0].sections[0].tally()

    puts "[%s]" % tally.join("][")

Most of the classes have to_s() methods that'll work for most cases.


