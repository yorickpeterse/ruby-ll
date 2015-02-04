module LL
  ##
  # Compiles an instance of {LL::CompiledConfiguration} which is used by
  # {LL::CodeGenerator} to actually generate Ruby source code.
  #
  class ConfigurationCompiler
    ##
    # @return [Hash]
    #
    TYPES = {
      :rule     => 0,
      :terminal => 1,
      :epsilon  => 2,
      :action   => 3
    }.freeze

    ##
    # @return [String]
    #
    DEFAULT_RUBY_CODE = 'val'.freeze

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [LL::CompiledConfiguration]
    #
    def generate(grammar)
      return CompiledConfiguration.new(
        :name          => generate_name(grammar),
        :namespace     => generate_namespace(grammar),
        :inner         => grammar.inner,
        :header        => grammar.header,
        :terminals     => generate_terminals(grammar),
        :actions       => generate_actions(grammar),
        :action_bodies => generate_action_bodies(grammar),
        :rules         => generate_rules(grammar),
        :table         => generate_table(grammar)
      )
    end

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [String]
    #
    def generate_name(grammar)
      return grammar.name.split('::').last
    end

    ##
    # @param [LL::CompiledGrammar] grammar
    # @return [Array]
    #
    def generate_namespace(grammar)
      parts = grammar.name.split('::')

      return parts.length > 1 ? parts[0..-2] : []
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
          args = branch.steps.reject { |step| step.is_a?(Epsilon) }.length

          actions << [:"_rule_#{index}", args]

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
          bodies[:"_rule_#{index}"] = branch.ruby_code || DEFAULT_RUBY_CODE

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
          row = [TYPES[:action], action_index]

          action_index += 1

          branch.steps.reverse_each do |step|
            if step.is_a?(LL::Terminal)
              row << TYPES[:terminal]
              row << term_indices[step]

            elsif step.is_a?(LL::Rule)
              row << TYPES[:rule]
              row << rule_indices[step]

            elsif step.is_a?(LL::Epsilon)
              row << TYPES[:epsilon]
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
            # For terminals we'll base the column index on the terminal index.
            if step.is_a?(Terminal)
              terminal_index = term_indices[step]

              table[rule_index][terminal_index] = branch_index

            # For the rest (= epsilon) we'll update all columns that haven't
            # been updated yet.
            else
              table[rule_index].each_with_index do |col, col_index|
                table[rule_index][col_index] = branch_index if col == -1
              end
            end
          end

          branch_index += 1
        end
      end

      return table
    end
  end # ConfigurationCompiler
end # LL
