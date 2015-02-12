# ruby-ll

ruby-ll is a high performance LL(1) table based parser generator for Ruby. The
parser driver is written in C/Java to ensure good runtime performance, the
compiler is written entirely in Ruby.

## Features

* Support for detecting first/first and first/follow conflicts
* clang-like error/warning messages to ease debugging parsers
* High performance and a low memory footprint

## Requirements

| Ruby     | Required      | Recommended |
|:---------|:--------------|:------------|
| MRI      | >= 1.9.3      | >= 2.1.0    |
| Rubinius | >= 2.2        | >= 2.5.0    |
| JRuby    | >= 1.7        | >= 1.7.0    |
| Maglev   | Not supported |             |
| Topaz    | Not supported |             |
| mruby    | Not supported |             |

For MRI/Rubinius you'll need a C90 compatible compiler such as clang or gcc. For
JRuby you don't need any compilers to be installed as the .jar is packaged with
the Gem itself.

## Grammar Syntax

TODO

## Usage

TODO

## Performance

TODO

## Thread Safety

TODO

## License

All source code in this repository is licensed under the MIT license unless
specified otherwise. A copy of this license can be found in the file "LICENSE"
in the root directory of this repository.
