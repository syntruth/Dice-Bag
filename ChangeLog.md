# DiceBag

## Version 3.3.3

- Introduce `average`, `maximum`, and `minimum` methods on the Roll
  object, which is handled by the `MinMaxCalc` service class. Max
  returns the highest roll possible, and min naturally returns the
  lowest roll possible, and average returns a float between those.
- Updated the `dicebag` executable to have new options for the above new
  methods.

## Version 3.3.2

- Update: Allow 4 digit numbers in dice strings.

## Version 3.3.1

- FIX: Issue with default no-value-given, explode option.
- FIX: `Transform.hashify_options` not handling a Hash argument
  smoothly.
- Allow `dicebag` executable to not need quotes around dice strings.
- Make `dicebag` executable handle not having any arguments better and
  added a `-h` option.

## Version 3.3.0

- Code refactoring and clean up.
- Bring things up to modern Ruby standards.
- Refactored the normalization step into it's own class.
- Removed confusing and unneeded options from pull-requests. Sorry, I
  should have noted this in the PR comments. :(
- Added `inspect` methods to most of the classes that also have custom
  `to_s` methods defined, just to clean up CLI results.
- Moved each of the 'example' game systems into their own lib folder,
  `systems` so they can be required directly. See README for more
  information.
- Added more tests!
- Created an executable, also called `dicebag` that will take the given
  string from the command-line and run it, printing out the result. If
  the `-n` or `--notes` option is given, then any generated notes will
  be printed after the result.
- Converted the ChangeLog to be a markdown file.
- Cleaned up the README file.

## Version 3.2.2

- Updated tests to check for missing count values. How this didn't
  happen earlier will have to remain a mystery of the ages. (>_>)
- Bugfix for #5
- Clean up in removing references to xdx hash to an actual hash
  variable. This plays into future plans on remoxing the :xdx hash
  earlier in the parse/transform pass.

## Version 3.2.1

- Refactored parts of the Transform class to 1.) fit better with
  accepted Parslet practices and 2.) better handle how sub-trees are
  handled, producing more predictable data from it.
- Refactored parts of the main DiceBag module to reflect changes that
  were done to the Transform class.
- Removed the #parse method override from the Parser class, since the
  logic fit better within the DiceBag#normalize_tree method.
- Refactored how the :options are parsed within the Parser class to make
  it a bit more clear what is going on there.
- Added tests for RollPartString and RollString modules.
- Updated tests to cover a few more things, as well as added the number
  list for the manually set srand value. (See comments in the
  dicebag_test.rb file.
- Reorganized the test/roll_part.rb to DRY it up a bit more.
- MOAR BUG FIXES.

## Version 3.2

- TESTS! Which needed to be done long ago. Really, no excuse. Bad,
  Syntruth, bad!
- BUG FIXES! Because of tests. Also, long overdue. Some really stupid
  bugs in there.

## Version 3.1.2

- General code clean up and some refactoring.
- Added roll_part_string.rb and roll_string.rb to modularize the #to_s
  methods for the RollPart and Roll classes. Part of the above clean up
  and refactoring.

## Version 3.1.1

- Updated RollPart#to_s to reflect xDx option strings. It was still
  using older ~ and ! for drop and keep options.

## Version 3.1.0

- Added the 't#' target number option to xDx strings. See the README
  file.
- Changed the ~ (drop) and ! (keep) xDx option sigils to be 'd' and 'k'
  respectively. This breaks slightly with tradition, but keeps things a
  bit more normalized option-sigil-wise. Or something.

## Version 3.0.4 and 3.0.5

- More minor, but critical fixes.

## Version 3.0.3

- Fixed a fatal bug in the Transform class in hashify_options.

## Version 3.0.1

- Code clean up.

## Version 3.0

- Totally rewritten to use the Parslet gem. Cleaner code, easier to
  extend.

## Versions < 3.0

This was an older, non-parslet version and not worth talking about. :)
