# Changelog

This document contains details of the various releases and their release dates.
Dates are in the format `yyyy-mm-dd`.

## 2.1.2 - 2015-06-03

### Fix for requiring extension on certain platforms

Certain platforms apparently no longer move compiled extensions into the lib/
directory. The code has been updated to use "require" instead to work around
this problem.

See commit b27fe7cc109a39184ac984405a1e452868f3fac9 for more information.

### License changed to MPL 2.0

Similar to Oga (and my other projects) the license of ruby-ll has been changed
to MPL 2.0.

See ruby-ll commit 59928ade94b9b849ffa827cb482662323066d041 and Oga commit
https://gitlab.com/yorickpeterse/oga/commit/0a7242aed44fcd7ef18327cc5b10263fd9807a35
for more information.

## 2.1.1 - 2015-03-22

This release adds Windows support for ruby-ll by tweaking the compilation
process of the native extensions. Tests are run on AppVeyor
(<https://ci.appveyor.com/project/yorickpeterse/ruby-ll>) to ensure they always
pass.

## 2.1.0 - 2015-03-20

### Question/Optional Operator Support

Support was added for the `?` operator. This operator can be used to indicate a
certain rule/terminal is optional.

### Bugfix when parsing parenthesis with an operator

This release fixes a bug in the parser that would occur when parsing input such
as the following:

    A = B (C D)? E;

This would previously throw a syntax error.

## 2.0.0 - 2015-03-18

This release contains some changes that are not backwards compatible, hence the
major version increase.

### Operator Support

Grammars can now use two new operators: `*` and `+`. The star operator (`*`)
defines that a set of terminals/rules can occur 0 or more times while the plus
operator (`+`) indicates that something occurs 1 or more times. These operators
don't rely on recursion and thus are left-associative.

### Branch Action Optimization

Branches containing only a single step without any custom actions now _only_
return the first step's value instead of an Array containing the value. In other
words, previously ruby-ll would generate an action returning `val` whereas now
it returns `val[0]`. This can break existing grammars, hence the major version
bump.

As an example:

    A = B;

Previously A would essentially be set to `[B]` whereas now it's just set to `B`.
This means you no longer have to do this:

    A = B { val[0] };

### CAPI Cleanups

Some of the C code used for the driver has been cleaned up to use correct CAPI
datatypes.

## 1.1.3 - 2015-02-17

The function `ll_driver_config_mark()` has been removed from the C extension as
it would occasionally trigger a segmentation fault. See commit
667339611d05fa58b60db58a7135156456dbd504 for more information.

## 1.1.2 - 2015-02-16

The file `ll/setup` now also loads `LL::ConfigurationCompiler` to ensure that
the `TYPES` array (and thus `LL::Driver#id_to_type`) can be used outside of
ruby-ll itself.

## 1.1.1 - 2015-02-16

Parser errors produced by ruby-ll's own parser/grammar now include the line
number/column number whenever possible.

## 1.1.0 - 2015-02-16

This release changes the way error handling is done. Instead of having multiple,
separate error callbacks there's now only one error callback:
`LL::Driver#parser_error`. See commit 22b6081e37509d10e3b31d6593b0a7f2e5fd7839
for more information.

While this change technically breaks backwards compatibility I do not consider
the old error handling system part of the public API, mainly due to it being
extremely painful to use.

## 1.0.0 - 2015-02-13

The first public release of ruby-ll!
