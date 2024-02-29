# Dice Bag: The Ruby Dice Rolling Library

**Name   :** Dice Bag Library for Ruby

**Author :** Randy Carnahan

**Version:** 3.3.0

**License:** LGPL OR MIT

The dice library for Ruby is an attempt to bring a standard interface to
every gamer's (RPG and otherwise) need to have dice rolled. The
centralized concept to this is taking a standard formatted string and
parsing it, returning values from that string.

The original inspiration for this library was the 'rolldice' Unix
command-line application. Since then, it's been added to to allow
additional elements in the dice string.

**Note:** prior versions of this library allowed for dice strings to be
"complex" in that there was more than one dice string, separated by
commas, to be parsed and returned. This feature was never really used,
so it's been removed to keep this newer version (3.0+) cleaner.

Starting with Version 3.0, this library now uses parslet, the excellent
Ruby syntax parser. It's made the internals a *bit* more complicated,
but has allowed greater flexibility in constructing dice strings. For
example, previous version, you had to do '4d6 e6 k3' if you wanted the
dice to explode (see below) and to keep the 3 highest rolls. Now, the e6
and k3 (and the other options) can be in any order after the xDx part of
the string.

## Installation

```sh
gem install dicebag
```

## Commandline Utility

As of version 3.3.0, a `dicebag` executable is installed as well. It's
nothing fancy, as it just simply takes a dice string and prints the
result to STDOUT.

If the `-n` or `--notes` flag is given, then any notes generated from the parsing of the dice string will be below the result.

```shell
$ dicebag 4d6 k3
16

# 1 is an invalid option for exploding dice!
$ dicebag --notes 1d4e1
1
For 1d4 e: Explode set to 4
```

## Usage

### Dice Strings

A dice string, also called the xDx string, that represents a single
group of dice, such as 3d10 or 4d6. Optional parts of the dice string
are given below.

A dice string is made up of one or more parts that consist of either:

- an optional label, which must be the first part of the string. Labels
  are defined within parenthesis.
- an xDx (such as 3d6) definition and options for that definition.
- modifiers that is applied to the current total. These are either
  static values or additional xDx strings.

The allowed static modifiers are add `+`, subtract `-`, multiply `*`,
and divide `/`. As the library (in the Roll class) iterates over the
parsed tree, a total for that roll is kept; the static modifiers are
applied *in the order they are gotten*, which is to say, the standard
order of arithmetic calculations do not apply.

For example:

```text
2d6 + 5 * 3 - 6
```

...would roll the 2d6 for the total, then add 5 to it, then multiply
that total by 3, and finally subtract 6. The 5 is not multiplied by 3
for a 15 and then added to the roll result. Just something to keep in
mind.

### Dice String Options

In the following section, note that # is used to denote the number part
of a option.

`xDx`: denotes how many dice to roll and how many sides the dice should
have. This is the standard RPG dice syntax. This *must* come before any
options for a given set of dice.

`e#`: the explode value. Some game systems call this 'open ended' dice.
If the number rolled is greater than or equal to the value given for
this option, the die is rolled again and added to the total. If no
number is given for this option, it is assumed to be the same as the
number of sides on the die. Thus, '1d6 e' is the same as '1d6 e6'.

`d#`: this denotes how many dice to drop from the tally. These dice are
dropped *before* any dice are kept with k# below. So, '5d6 d2' means
roll five 6-sided dice and drop the lowest 2 values. If the given value
(combined with how many dice to keep) are greater than the number of
dice in the xDx string, this value will be reset to 0.

`k#`: this denotes how many dice to keep out of the number of dice
rolled, keeping the highest values from the roll. Thus, '4d6 k3' means
to roll four 6-sided dice and keep the best 3 values. If the given value
(combined with how many dice to drop) are greater than the number of
dice in the xDx string, this value will be reset to 0.

`r#`: this denotes a reroll value. If the die rolls this value or less,
then the die is rolled again. Thus, '1d6 r3' will only return a result
of 4, 5, or 6. If the given value is larger than the number of sides on
the die, then it is reset to 0.

`t#`: this denotes a target number that each die in the roll must match
or exceed to count as a 'success'. That is, the dice in the roll are
*not* added together for a total, but any die that meets or exceeds the
target number is added to a total of successes. For example, '5d10 t8'
means roll five 10-sided dice and each die that is 8 or higher is a
success. (Similar to WhiteWolf games.) If this option is given a 0
value, that is the same as not having the option at all; that is, a
normal sum of all dice in the roll is performed instead. 

`f#`: this denotes a failure number that each dice must match or be
beneath in order to count against successes. These work as a sort of
negitive successes and are totaled together as described above. For
example, '5d10 t8 f1' means roll five 10-sided dice and each die that is
8 or higher is a success and subtract each one. (Like in WhiteWolf
games.) Because of this, the total may be negative. If this option is
given a 0 value, that is the same as not having the option at all; that
is, a normal sum of all dice in the roll is performed instead.

**Note:** if any value is reset because of a validation failure, a note is
attached to the Roll.

### Dice String Limitations

Within the dice library itself, simple (xDx) strings are limited to 3
digits for all parts of the string. This is to prevent honkin' huge
numbers that *some* users abuse to lag out the dice rolling process.

## Using the Dice Library

Using the library is rather straight forward:

```ruby
require 'dicebag'

dstr   = "(Damage) 2d8 + 5 + 1d6"
dice   = DiceBag::Roll.new(dstr)
result = dice.result()

puts result
```

This would output something like the following:

```text
Damage: 15
```

Or, if your needs are just knowing the results, you can use the
shorthand method of `DiceBag.roll`, which returns a `Result`:

```ruby
puts DiceBag.roll('4d6 d1')
```

The returned result from `Roll#result` is an instance of the `Result`
class, which has methods to access the label (if any), the total of the
roll, and also each of the sections that made up the roll.

It is possible to get the individual sections values as well:

```ruby
result.each do |section|
  puts "%s: %s" % [section, section.total]
end
```

For the above given dice string, would print something like this:

```text
2d8: 7
  5: 5
1d6: 3
```

Also, if you are curious to see how the dice string was parsed, you can
retrieved the parsed value from the `Roll` instance using the `#tree`
method:

```ruby
parsed = dice.tree()
```

For the above given dice string, this returns a nested array of values:

```ruby
[[:label, <DiceBag::LabelPart (Damage)>],
 [:start, <DiceBag::RollPart 2d8>],
 [:add, <DiceBag::StaticPart 5>],
 [:add, <DiceBag::RollPart 1d6>]]
```

Typically, you won't have to deal with the internals of a dice roll if
all you want are the results. However, you can dig down into the
returned result's classes to obtain pretty much any data you want. Most,
if not all, of the instance properties have attr accessors set up.

For example, if you wanted to know the actual dice tally of a '4d6 k3'
roll, you could do this, after getting the result from
Dice::Roll.result():

```ruby
result = Dice::Roll.new("4d6 k3").result()
tally  = result[0].sections[0].tally()

puts "[%s]" % tally.join("][")
```

All of the classes have `to_s` and `inspect` methods that'll work for
most cases.

## Included RPG Systems Dice

There are some pre-built dice libraries based on popular (and some not as popular) RPGs, that are not required by default, but can be loaded via the paths given below.

The following RPG system dice are included in this update:

### Dungeons and Dragons

This loads the `D20`, `D20Advantage`, and `D20Disadvantage` classes. The
results will return a two item array, consisting of the success result
as a symbol and the actual die roll result. Note, for Advantage and
Disadvantage, only the die result used is displayed.

Each of the `roll` calls takes a +/- modifier and a Difficulty Class
(which defaults to 10).

```ruby
require 'dicebag/systems/dnd'

# 1d20 + 5 >= DC 10
D20.roll 5

# 1d20 >= DC 15
D20.roll 0, 15

# 1d20 twice, keep the highest >= DC 10
D20Advantage.roll

# 1d20 twice, keep the lowest >= DC 10
D20Disadvantage.roll
```

### Fudge/FATE

This load the Fudge (and FATE) usable dice. By default it will roll 4dF
and will return a two element array, consisting of the total and a
string representation of the dice results.

They can be rolled via the `Fudge::Roll` class, or the syntactic sugar
of either `Fudge::DF` or `Fudge.roll`. The last one can take an optional
number of dice to roll, but still defaults to 4.

```ruby
require 'dicebag/systems/fudge'

# Rolls the standard 4dF
result = Fudge.roll

puts result.first # => -1
puts result.last  # => [-][-][+][ ]
```

### GURPS

This models the standard GURPS 3d6 dice pool used for attribute/skill
tests.

Use the `GURPS.roll(target, mod = 0)` method, which will figure the
total target number based on the given target value and the mod,
calculating the critical success and failure numbers based on that
total.

The result will return an array of [status, result] where:

- status is one of:
   :success, :failure, :critical_success, or :critical_failure
- result is the actual dice roll total.

```ruby
require 'dicebag/systems/gurps'

GURPS.roll 15 # => [:success, 6]

GURPS.roll 15 # => [:critical_success, 4]

GURPS.roll 15 # => [:failure, 16]

GURPS.roll 16, 3 # => [:critical_success, 6]
```

### Savage Worlds

This loads the standard `D4` through `D12`, plus the additional objects
of `WildDie`, `NoTrait`, and `NoTraitWildDie`, each of which are
subclasses of `DiceBag::Roll` so each expose their own `roll` method to
use directly.

Both of the `NoTrait` and `NoTraitWildDie` types automatically have the
-2 applied.

At this time, each one does not take any additional modifiers to the
roll, so you will have to handle that externally.

All of the Savage Worlds dice are keys to explode ('Ace' in Savage
Worlds terminology), so for normal rolls for tables, etc, use the
standard dice definitions below.

```ruby
require 'dicebag/systems/savage_worlds'

# Models a 1d4e+2 for a Trait roll.
SavageWorlds::D4.roll.total + 2 # => 8 (It exploaded!)
```

### Standard

They are just that, the standard dice under the `Standard` module.

```ruby
require 'dicebag/systems/standard'
```

```ruby
> puts Standard.constants
Die
D4
D6
D8
D10
D12
D20
D100
```

### Storyteller

This models the WhiteWolf systems dice pool mechanics.

This is actually modeling the "Storytelling" system dice, not the older
"Storyteller" system dice, but I personally find "Storytelling" kind of
a silly name, so I prefer the older name. :D

There is a `Storyteller.roll(number, success)` method to roll the number
of d10s and count how many successes (>= success value) are generated.
There is also a `Storyteller.chance` method that will roll a since
1d10/10 dice.

```ruby
require 'dicebag/systems/storyteller'
```
