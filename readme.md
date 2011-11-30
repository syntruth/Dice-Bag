Ruby Dice Lib
=============

**Name   :** Dice Library for Ruby

**Author :** Randy Carnahan

**Version:** 2.5

**License:** LGPL

The dice library for Ruby is an attempt to bring a standard interface
to every gamer's (RPG and otherwise) need to have dice rolled. The 
centralized concept to this is taking a standard formatted string and
parsing it, returning values from that string.

Dice Strings
------------

There are two types of dice strings in this library:

**Simple Dice String**

A simple dice string, also called the xDx string, that represents a
single group of dice, such as 3d10 or 4d6. Optional parts of the 
Simple Dice string are given below.

**Complex Dice Strings**

A complex dice string is a string that is made up of one or more
Simple Dice strings, static +/- values, and optional Label parts, 
separated by commas.

An example of a complex dice string is:

  (Attack) 1d20 + 8, (Damage) 2d4 + 7 + 1d6 - 2 

Note, that spaces in the strings are optional, but the string is 
easier to read if there are spaces.

Simple Dice String Options
--------------------------

In the following section, note that # is used to denote the number
part of a option.

The options are given in the order they should appear in the simple
dice string.

**xDx** - denotes how many dice to roll and how many sides the dice
should have. This is the standard RPG dice syntax. Note that if the 
sides of the die is given as '%' it will be converted to 100 
automatically.

**e#** - the explode value. Some game systems call this 'open ended'
dice. If the number rolled is greater than or equal to the value given
for this option, the die is rolled again and added to the total. If no
number is given for this option, it is assumed to be the same as the
number of sides on the die. Thus, '1d6e6' is the same as '1d6e'.

**!#** - this denotes how many dice to keep out of the number of dice
rolled, keeping the highest values from the roll. Thus, '4d6 !3' means
to roll four 6-sided dice and keep the best 3 values.

**r#** - this denotes a reroll value. If the die rolls this value or 
less, then the die is rolled again. Thus, '1d6r3' will only return a 
result of 4, 5, or 6. If the given value is larger than the number of
sides on the die, then it defaults to the sides - 1.

**\*#** - this denotes a multiplier to the result of the dice roll. Note
that this option is applied **after** the dice have been rolled, coming 
after any exploding or rerolling dice. Thus, '3d4 *10' will result in 
a range of 30 to 120, while '3d4 r1 *10' will result in a range of 20 to
120.

Dice String Limitations
-----------------------

Within the dice library itself, simple (xDx) strings are limited to 2
digits for all parts of the string except for the sides of the given
die, which can be up to 3 digits.

Using the Dice Library
----------------------

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

Also, if you are curious to see how the complex dice string was parsed,
you can retrieved the parsed value from the Roll instance using the
parsed() method:

    parsed = roll.parsed()

For the above given dice string, this returns a nested array of values:

    [
      [
        [:label, "Damage"],
        [:start, "2d8"],
        [:add, 5],
        [:add, "1d6"]
      ]
    ]

...note, however, that each sections 2nd element is actually a class 
instance of SimplePart or one of it's subclasses. I used strings above
to simply show the format.

Typically, you won't have to deal with the internals of a dice roll if all
you want are the results. However, you can dig down into the returned
result's classes to obtain pretty much any data you want.

For example, if you wanted to know the actual dice tally of a '4d6 !3' roll,
you could do this, after getting the result from Dice::Roll.result():

    result = Dice::Roll.new("4d6 !3").result()

    tally = result[0].sections[0].tally()

    puts "[%s]" % tally.join("][")

Most of the classes have to_s() methods that'll work for most cases.


