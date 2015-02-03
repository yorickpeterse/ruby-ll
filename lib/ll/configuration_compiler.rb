module LL
  ##
  # Compiles an instance of {LL::CompiledConfiguration} which is used by
  # {LL::CodeGenerator} to actually generate Ruby source code.
  #
  class ConfigurationCompiler
    ##
    # Number to indicate the start of a rule.
    #
    # @return [Fixnum]
    #
    RULE = 0

    ##
    # Number to indicate the start of a terminal.
    #
    # @return [Fixnum]
    #
    TERMINAL = 1

    ##
    # Number to indicate the start of an epsilon.
    #
    # @return [Fixnum]
    #
    EPSILON = 2

    ##
    # Number to indicate the start of an action.
    #
    # @return [Fixnum]
    #
    ACTION = 3

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [LL::CompiledConfiguration]
    #
    def generate(grammar)
      return CompiledConfiguration.new(
        :terminals     => generate_terminals(grammar),
        :actions       => generate_actions(grammar),
        :action_bodies => generate_action_bodies(grammar),
        :rules         => generate_rules(grammar),
        :table         => generate_table(grammar)
      )
    end

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [Array]
    #
    def generate_terminals(grammar)
      return grammar.terminals.map { |term| term.name.to_sym }
    end

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [Array]
    #
    def generate_actions(grammar)
      actions = []
      index   = 0

      grammar.rules.each do |rule|
        rule.branches.each do |branch|
          next unless branch.ruby_code

          actions << [:"_rule_#{index}", branch.steps.length]

          index += 1
        end
      end

      return actions
    end

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [Hash]
    #
    def generate_action_bodies(grammar)
      bodies = {}
      index  = 0

      grammar.rules.each do |rule|
        rule.branches.each do |branch|
          next unless branch.ruby_code

          bodies[:"_rule_#{index}"] = branch.ruby_code

          index += 1
        end
      end

      return bodies
    end

    ##
    # Builds the rules table of the parser. Each row is built in reverse order.
    #
    # @param [LL::CompiledGrammar] grammar
    # @return [Array]
    #
    def generate_rules(grammar)
      rules        = []
      action_index = 0
      rule_indices = grammar.rule_indices
      term_indices = grammar.terminal_indices

      grammar.rules.each_with_index do |rule, rule_index|
        rule.branches.each do |branch|
          row = []

          if branch.ruby_code
            row << ACTION
            row << action_index

            action_index += 1
          end

          branch.steps.reverse_each do |step|
            if step.is_a?(LL::Terminal)
              row << TERMINAL
              row << term_indices[step]

            elsif step.is_a?(LL::Rule)
              row << RULE
              row << rule_indices[step]

            elsif step.is_a?(LL::Epsilon)
              row << EPSILON
              row << 0
            end
          end

          rules << row
        end
      end

      return rules
    end

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [Array]
    #
    def generate_table(grammar)
      branch_index = 0
      term_indices = grammar.terminal_indices

      table = Array.new(grammar.rules.length) do
        Array.new(grammar.terminals.length, -1)
      end

      grammar.rules.each_with_index do |rule, rule_index|
        rule.branches.each do |branch|
          branch.first_set.each do |step|
            next unless step.is_a?(LL::Terminal)

            terminal_index = term_indices[step]

            table[rule_index][terminal_index] = branch_index
          end

          branch_index += 1
        end
      end

      return table
    end
  end # ConfigurationCompiler
end # LL
