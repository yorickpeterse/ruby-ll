# ruby-ll

ruby-ll is a high performance LL(1) table based parser generator for Ruby. The
parser driver is written in C/Java to ensure good runtime performance, the
compiler is written entirely in Ruby.

ruby-ll was written to serve as a fast and easy to use alternative to
[Racc][racc] for the various parsers used in [Oga][oga]. However, ruby-ll isn't
limited to just Oga, you can use it to write a parser for any language that can
be represented using an LL(1) grammar.

ruby-ll is self-hosting, this allows one to use ruby-ll to modify its own
parser. Self-hosting was achieved by bootstrapping the parser using a Racc
parser that outputs the same AST as the ruby-ll parser. The Racc parser remains
in the repository for historical purposes and in case it's ever needed again, it
can be found in [bootstrap/parser.y](lib/ll/bootstrap/parser.y).

For more information on LL parsing, see
<https://en.wikipedia.org/wiki/LL_parser>.

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

When hacking on Oga you'll also need to have the following installed:

* Ragel 6 for building the grammar lexer
* javac for building the JRuby extension

## Grammar Syntax

The syntax of a ruby-ll grammar file is fairly simple and consists out of
directives, rules, comments and code blocks.

Directives can be seen as configuration options, for example to set the name of
the parser class. Rules are, well, the parsing rules. Code blocks can be used to
associate Ruby code with either a branch of a rule or a certain section of the
parser (the header or its inner body).

Directives and rules must be terminated using a semicolon, this is not needed
for `%inner` / `%header` blocks.

### Comments

Comments start with a hash (`#`) sign and continue until the end of the line,
just like Ruby. Example:

    # Some say comments are a code smell.

### %name

The `%name` directive is used to set the full name/namespace of the parser
class. The name consists out of a single identifier or multiple identifiers
separated by `::` (just like Ruby). Some examples:

    %name A;
    %name A::B;
    %name A::B::C;

The last identifier is used as the actual class name. This class will be nested
inside a module for every other segment leading up to the last one. For example,
this:

    %name A;

Gets turned into this:

    class A < LL::Driver

    end

While this:

    %name A::B::C;

Gets turned into this:

    module A
    module B
    class C < LL::Driver

    end
    end
    end

By nesting the parser class in modules any constants in the scope can be
referred to without requiring the use of a full namespace. For example, the
constant `A::B::X` can just be referred to as `X` in the above example.

Multiple calls to this directive will result in previous values being
overwritten.

### %terminals

The `%terminals` directive is used to list one or more terminals of the grammar.
Each terminal is an identifier separated by a space. For example:

    %terminals A B C;

This would define 3 terminals: `A`, `B` and `C`. While there's no specific
requirement as to how you name your terminals it's common practise to capitalize
them and prefix them with `T_`, like so:

    %terminals T_A T_B T_C;

Multiple calls to this directive will result in the terminals being appended to
the existing list.

### %inner

The `%inner` directive can be used to specify a code block that should be placed
inside the parser's body, just after the section containing all parsing tables.
This directive should be used for adding custom methods and such to the parser.
For example:

    %inner
    {
      def initialize(input)
        @input = input
      end
    }

This would result in the following:

    class A < LL::Driver
      def initialize(input)
        @input = input
      end
    end

Curly braces can either be placed on the same line as the `%inner` directive or
on a new line, it's up to you.

Unlike regular directives this directive should not be terminated using a
semicolon.

### %header

The `%header` directive is similar to the `%inner` directive in that it can be
used to add a code block to the parser. The code of this directive is placed
just before the `class` definition of the parser. This directive can be used to
add documentation to the parser class. For example:

    %header
    {
      # Hello world
    }

This would result in the following:

    # Hello world
    class A < LL::Driver
    end

### Rules

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

[racc]: https://github.com/tenderlove/racc
[oga]: https://github.com/yorickpeterse/oga
