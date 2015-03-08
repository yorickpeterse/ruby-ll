# This file is automatically generated by ruby-ll. Manually changing this file
# is not recommended as any changes will be lost the next time this parser is
# re-generated.

module LL
class Parser < LL::Driver
  CONFIG = LL::DriverConfig.new

  CONFIG.terminals = [
    :$EOF, # 0
    :T_RUBY, # 1
    :T_NAME, # 2
    :T_TERMINALS, # 3
    :T_INNER, # 4
    :T_HEADER, # 5
    :T_IDENT, # 6
    :T_EQUALS, # 7
    :T_COLON, # 8
    :T_PIPE, # 9
    :T_EPSILON, # 10
    :T_SEMICOLON, # 11
    :T_STAR, # 12
    :T_PLUS, # 13
    :T_QUESTION, # 14
  ].freeze

  CONFIG.rules = [
    [3, 0, 0, 1], # 0
    [3, 1, 2, 0], # 1
    [3, 2, 0, 1, 0, 2], # 2
    [3, 3, 2, 0], # 3
    [3, 4, 0, 23], # 4
    [3, 5, 0, 3], # 5
    [3, 6, 0, 5], # 6
    [3, 7, 0, 6], # 7
    [3, 8, 0, 7], # 8
    [3, 9, 1, 11, 0, 4, 0, 10, 1, 2], # 9
    [3, 10, 0, 4, 0, 10, 1, 8, 1, 8], # 10
    [3, 11, 2, 0], # 11
    [3, 12, 1, 11, 0, 8, 1, 3], # 12
    [3, 13, 0, 20, 1, 4], # 13
    [3, 14, 0, 20, 1, 5], # 14
    [3, 15, 0, 9, 0, 10], # 15
    [3, 16, 0, 8], # 16
    [3, 17, 2, 0], # 17
    [3, 18, 1, 6], # 18
    [3, 19, 0, 12, 0, 13], # 19
    [3, 20, 0, 11], # 20
    [3, 21, 2, 0], # 21
    [3, 22, 0, 14, 0, 10], # 22
    [3, 23, 0, 15], # 23
    [3, 24, 2, 0], # 24
    [3, 25, 1, 13], # 25
    [3, 26, 1, 12], # 26
    [3, 27, 1, 14], # 27
    [3, 28, 0, 11], # 28
    [3, 29, 0, 17], # 29
    [3, 30, 1, 10], # 30
    [3, 31, 0, 19, 0, 16], # 31
    [3, 32, 0, 20], # 32
    [3, 33, 2, 0], # 33
    [3, 34, 1, 1], # 34
    [3, 35, 0, 22, 0, 18], # 35
    [3, 36, 0, 21, 1, 9], # 36
    [3, 37, 2, 0], # 37
    [3, 38, 1, 11, 0, 21, 1, 7, 0, 10], # 38
  ].freeze

  CONFIG.table = [
    [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0], # 0
    [3, 3, 2, 2, 2, 2, 2, 3, 3, 3, 3, 3, 3, 3, 3], # 1
    [-1, -1, 5, 6, 7, 8, 4, -1, -1, -1, -1, -1, -1, -1, -1], # 2
    [-1, -1, 9, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], # 3
    [11, 11, 11, 11, 11, 11, 11, 11, 10, 11, 11, 11, 11, 11, 11], # 4
    [-1, -1, -1, 12, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], # 5
    [-1, -1, -1, -1, 13, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], # 6
    [-1, -1, -1, -1, -1, 14, -1, -1, -1, -1, -1, -1, -1, -1, -1], # 7
    [-1, -1, -1, -1, -1, -1, 15, -1, -1, -1, -1, -1, -1, -1, -1], # 8
    [17, 17, 17, 17, 17, 17, 16, 17, 17, 17, 17, 17, 17, 17, 17], # 9
    [-1, -1, -1, -1, -1, -1, 18, -1, -1, -1, -1, -1, -1, -1, -1], # 10
    [-1, -1, -1, -1, -1, -1, 19, -1, -1, -1, -1, -1, -1, -1, -1], # 11
    [21, 21, 21, 21, 21, 21, 20, 21, 21, 21, 21, 21, 21, 21, 21], # 12
    [-1, -1, -1, -1, -1, -1, 22, -1, -1, -1, -1, -1, -1, -1, -1], # 13
    [24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 24, 23, 23, 23], # 14
    [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 26, 25, 27], # 15
    [-1, -1, -1, -1, -1, -1, 28, -1, -1, -1, 29, -1, -1, -1, -1], # 16
    [-1, -1, -1, -1, -1, -1, -1, -1, -1, -1, 30, -1, -1, -1, -1], # 17
    [-1, -1, -1, -1, -1, -1, 31, -1, -1, -1, 31, -1, -1, -1, -1], # 18
    [33, 32, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33, 33], # 19
    [-1, 34, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1, -1], # 20
    [-1, -1, -1, -1, -1, -1, 35, -1, -1, -1, 35, -1, -1, -1, -1], # 21
    [37, 37, 37, 37, 37, 37, 37, 37, 37, 36, 37, 37, 37, 37, 37], # 22
    [-1, -1, -1, -1, -1, -1, 38, -1, -1, -1, -1, -1, -1, -1, -1], # 23
  ].freeze

  CONFIG.actions = [
    [:_rule_0, 1], # 0
    [:_rule_1, 0], # 1
    [:_rule_2, 2], # 2
    [:_rule_3, 0], # 3
    [:_rule_4, 1], # 4
    [:_rule_5, 1], # 5
    [:_rule_6, 1], # 6
    [:_rule_7, 1], # 7
    [:_rule_8, 1], # 8
    [:_rule_9, 4], # 9
    [:_rule_10, 4], # 10
    [:_rule_11, 0], # 11
    [:_rule_12, 3], # 12
    [:_rule_13, 2], # 13
    [:_rule_14, 2], # 14
    [:_rule_15, 2], # 15
    [:_rule_16, 1], # 16
    [:_rule_17, 0], # 17
    [:_rule_18, 1], # 18
    [:_rule_19, 2], # 19
    [:_rule_20, 1], # 20
    [:_rule_21, 0], # 21
    [:_rule_22, 2], # 22
    [:_rule_23, 1], # 23
    [:_rule_24, 0], # 24
    [:_rule_25, 1], # 25
    [:_rule_26, 1], # 26
    [:_rule_27, 1], # 27
    [:_rule_28, 1], # 28
    [:_rule_29, 1], # 29
    [:_rule_30, 1], # 30
    [:_rule_31, 2], # 31
    [:_rule_32, 1], # 32
    [:_rule_33, 0], # 33
    [:_rule_34, 1], # 34
    [:_rule_35, 2], # 35
    [:_rule_36, 2], # 36
    [:_rule_37, 0], # 37
    [:_rule_38, 4], # 38
  ].freeze

  ##
  # @see [LL::Lexer#initialize]
  #
  def initialize(*args)
    @lexer = Lexer.new(*args)
  end

  ##
  # @yieldparam [Symbol] type
  # @yieldparam [String] value
  #
  def each_token
    @lexer.advance do |token|
      yield [token.type, token]
    end

    yield [-1, -1]
  end

  ##
  # @see [LL::AST::Node#initialize]
  #
  def s(*args)
    return AST::Node.new(*args)
  end

  ##
  # @see [LL::Driver#parser_error]
  #
  def parser_error(stack_type, stack_value, token_type, token_value)
    message = parser_error_message(stack_type, stack_value, token_type)

    if token_value.is_a?(LL::Token)
      sl       = token_value.source_line
      message += " (line #{sl.line}, column #{sl.column})"
    end

    raise ParserError, message
  end

  def _rule_0(val)
     s(:grammar, val[0]) 
  end

  def _rule_1(val)
     s(:grammar) 
  end

  def _rule_2(val)
     val[0] + val[1] 
  end

  def _rule_3(val)
    val
  end

  def _rule_4(val)
    val
  end

  def _rule_5(val)
    val
  end

  def _rule_6(val)
    val
  end

  def _rule_7(val)
    val
  end

  def _rule_8(val)
    val
  end

  def _rule_9(val)
    
      s(:name, [val[1], *val[2]], :source_line => val[0].source_line)
    
  end

  def _rule_10(val)
     [val[2], *val[3]] 
  end

  def _rule_11(val)
    val
  end

  def _rule_12(val)
    
      s(:terminals, val[1], :source_line => val[0].source_line)
    
  end

  def _rule_13(val)
    
      s(:inner, [val[1]], :source_line => val[0].source_line)
    
  end

  def _rule_14(val)
    
      s(:header, [val[1]], :source_line => val[0].source_line)
    
  end

  def _rule_15(val)
     [val[0], *val[1]] 
  end

  def _rule_16(val)
     val[0] 
  end

  def _rule_17(val)
    val
  end

  def _rule_18(val)
    
      s(:ident, [val[0].value], :source_line => val[0].source_line)
    
  end

  def _rule_19(val)
     [val[0], *val[1]] 
  end

  def _rule_20(val)
     val[0] 
  end

  def _rule_21(val)
    val
  end

  def _rule_22(val)
    
      val[1] ? s(val[1][0], [val[0]], :source_line => val[1][1]) : val[0]
    
  end

  def _rule_23(val)
     val[0] 
  end

  def _rule_24(val)
     nil 
  end

  def _rule_25(val)
     [:plus, val[0].source_line] 
  end

  def _rule_26(val)
     [:star, val[0].source_line] 
  end

  def _rule_27(val)
     [:question, val[0].source_line] 
  end

  def _rule_28(val)
    
      s(:steps, val[0], :source_line => val[0][0].source_line)
    
  end

  def _rule_29(val)
    
      s(:steps, [val[0]], :source_line => val[0].source_line)
    
  end

  def _rule_30(val)
     s(:epsilon, [], :source_line => val[0].source_line) 
  end

  def _rule_31(val)
    
      steps = [val[0]]

      steps << val[1] if val[1]

      s(:branch, steps, :source_line => val[0].source_line)
    
  end

  def _rule_32(val)
     val[0] 
  end

  def _rule_33(val)
     nil 
  end

  def _rule_34(val)
     s(:ruby, [val[0].value], :source_line => val[0].source_line) 
  end

  def _rule_35(val)
     [val[0], *val[1]] 
  end

  def _rule_36(val)
     val[1] 
  end

  def _rule_37(val)
    val
  end

  def _rule_38(val)
    
      s(:rule, [val[0], *val[2]], :source_line => val[0].source_line)
    
  end
end
end
