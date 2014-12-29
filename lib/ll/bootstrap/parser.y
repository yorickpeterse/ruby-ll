##
# Parser used for bootstrapping ruby-ll's own LL(1) parser.
#
class LL::Bootstrap::Parser

token T_RUBY T_NAME T_TOKENS T_INNER T_HEADER T_IDENT T_EQUALS T_COLON T_PIPE
token T_STAR T_PLUS T_QUESTION T_EPSILON T_SEMICOLON

options no_result_var

rule
  grammar
    : elements
    | /* none */
    ;

  elements
    : elements element
    | element
    ;

  element
    : directive
    | rule
    ;

  directive
    : name
    | tokens
    | inner
    | header
    ;

  # %name directives

  name
    : T_NAME T_IDENT T_SEMICOLON
    | T_NAME T_IDENT name_ns T_SEMICOLON
    ;

  name_ns
    : T_COLON T_COLON T_IDENT
    | T_COLON T_COLON T_IDENT name_ns
    ;

  # %tokens directive

  tokens
    : T_TOKENS idents T_SEMICOLON
    ;

  # Code directives

  inner
    : T_INNER T_RUBY
    ;

  header
    : T_HEADER T_RUBY
    ;

  # Generic identifiers

  idents
    : ident
    | idents ident
    ;

  ident
    : T_IDENT
    ;

  # Identifiers with/without named captures and/or operators.

  idents_or_epsilon
    : idents_or_captures
    | T_EPSILON
    ;

  idents_or_captures
    : ident_or_capture
    | idents_or_captures ident_or_capture
    ;

  ident_or_capture
    : ident_or_capture_
    | ident_or_capture_ operator
    ;

  ident_or_capture_
    : ident
    | capture
    ;

  capture
    : ident T_COLON ident
    ;

  # Rules

  branch
    : idents_or_epsilon
    | idents_or_epsilon T_RUBY
    ;

  branches
    : branch
    | branch T_PIPE branches
    ;

  rule
    : ident T_EQUALS branches T_SEMICOLON
    ;

  # Operators

  operator
    : T_STAR
    | T_PLUS
    | T_QUESTION
    ;
end

---- inner
  ##
  # @see [LL::Lexer#initialize]
  #
  def initialize(*args)
    @lexer = Lexer.new(*args)
  end

  ##
  # Yields the next token from the lexer.
  #
  # @yieldparam [Array]
  #
  def yield_next_token
    @lexer.advance do |type, value, source_line|
      @source_line = source_line

      yield [type, value]
    end

    yield [false, false]
  ensure
    @source_line = nil
  end

  ##
  # @param [Symbol] type
  # @param [Array] children
  # @return [LL::AST::Node]
  #
  def s(type, *children)
    return AST::Node.new(type, children, :source_line => @source_line)
  end

  ##
  # Parses the input and returns the corresponding AST.
  #
  # @return [LL::AST::Node]
  #
  def parse
    return yyparse(self, :yield_next_token)
  end

# vim: set ft=racc:
