# Changelog

This document contains details of the various releases and their release dates.
Dates are in the format `yyyy-mm-dd`.

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
