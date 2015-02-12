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

## Usage

The CLI takes a grammar input file (see below for the exact syntax) with the
extension `.rll` and turns it into a corresponding Ruby file. For example:

    ruby-ll lib/my-gem/parser.rll

This would result in the parser being written to `lib/my-gem/parser.rb`. If you
want to customize the output path you can do so using the `-o` / `--output`
options:

    ruby-ll lib/my-gem/parser.rll -o lib/my-gem/my-parser.rb

By default ruby-ll adds various `require` calls to ensure you can load the
parser _without_ having to load all of ruby-ll (e.g. the compiler code). If you
want to disable this behaviour you can use the `--no-requires` option when
processing a grammar:

    ruby-ll lib/my-gem/parser.rll --no-requires

Once generated you can use the parser class like any other parser. To start
parsing simply call the `parse` method:

    parser = MyGem::Parser.new

    parser.parse

The return value of this method is whatever the root rule (= the first rule
defined) returned.

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

Rules consist out of a name followed by an equals sign (`=`) followed by 1 or
more branches. Each branch is separated using a pipe (`|`). A branch can consist
out of 1 or many steps, or an epsilon. Branches can be followed by a code block
starting with `{` and ending with `}`. A rule must be terminated using a
semicolon.

An epsilon is represented as a single underscore (`_`) and is used to denote a
wildcard/nothingness.

A simple example:

    %terminals A;

    numbers = A | B;

Here the rule `numbers` is defined and has two branches. If we wanted a rule
that would match terminal `A` or nothing we'd use the following:

    %terminals A;

    numbers = A | _;

Code blocks can also be added:

    numbers
      = A { 'A' }
      | B { 'B' }
      ;

When the terminal `A` would be processed the returned value would be "B", for
terminal `B` the returned value would be "B".

Code blocks have access to an array called `val` which contains the values of
every step of a branch. For example:

    numbers = A B { val };

Here `val` would return `[A, B]`. Since `val` is just an Array you can also
return specific elements from it:

    numbers = A B { val[0] };

Values returned by code blocks are passed to whatever other rule called it. This
allows code blocks to be used for building ASTs and the likes. If no explicit
code block is defined `val` is returned as is.

ruby-ll parsers recurse into rules before unwinding, this means that the
inner-most rule is processed first.

Branches of a rule can also refer to other rules:

    numbers    = A other_rule;
    other_rule = B;

The value for `other_rule` in the `numbers` rule would be whatever the
`other_rule` below it returns.

The grammar compiler adds errors whenever it encounters a rule with the same
name as a terminal, as such the following is invalid:

    %terminals A B;

    A = B;

It's also an error to re-define an existing rule.

## Conflicts

LL(1) grammars can have two kinds of conflicts in a rule:

* first/first
* first/follow

### first/first

A first/first conflict means that multiple branches of a rule start with the
same terminal, resulting in the parser being unable to choose what branch to
use. For example:

    %terminals A B;

    rule = A | A B;

This would result in the following output:

    example.rll:5:1:error: first/first conflict, multiple branches start with the same terminals
    rule = A | A B;
    ^
    example.rll:5:8:error: branch starts with: A
    rule = A | A B;
           ^
    example.rll:5:12:error: branch starts with: A
    rule = A | A B;
               ^

To solve a first/first conflict you'll have to factor out the common left
factor. For example:

    %name Example;

    %terminals A B;

    rule        = A rule_follow;
    rule_follow = B | _;

Here the `rule` rule starts with terminal `A` and can optionally be followed by
`B`, without introducing any first/first conflicts.

### first/follow

A first/follow conflict occurs when a branch in a rule starts with an epsilon
and is followed by one or more terminals and/or rules. An example of a
first/follow conflict:

    %name Example;

    %terminals A B;

    rule       = other_rule B;
    other_rule = A | _;

This produces the following errors:

    example.rll:5:14:error: first/follow conflict, branch can start with epsilon and is followed by (non) terminals
    rule       = other_rule B;
                 ^
    example.rll:6:18:error: epsilon originates from here
    other_rule = A | _;
                     ^

There's no specific procedure to solving such a conflict other than simply
removing the starting epsilon.

## Performance

One of the goals of ruby-ll is to be faster than existing parser generators,
Racc in particular. How much faster ruby-ll will be depends on the use case. For
example, for the benchmark
[benchmark/ll/simple\_json\_bench.rb](benchmark/l/simple_json_bench.rb) the
performance gains of ruby-ll over Racc are as following:

| Ruby            | Speed |
|:----------------|:------|
| MRI 2.2         | 1.75x |
| Rubinius 2.5.2  | 3.85x |
| JRuby 1.7.18    | 6.44x |
| JRuby 9000 pre1 | 7.50x |

This benchmark was run on a Thinkpad T520 laptop so it's probably best to run
the bencharmk yourself to see how it behaves on your platform.

Depending on the complexity of your parser you might end up with different
different numbers. The above metrics are simply an indication of the maximum
performance gain of ruby-ll compared to Racc.

## Thread Safety

TODO

## License

All source code in this repository is licensed under the MIT license unless
specified otherwise. A copy of this license can be found in the file "LICENSE"
in the root directory of this repository.

[racc]: https://github.com/tenderlove/racc
[oga]: https://github.com/yorickpeterse/oga
