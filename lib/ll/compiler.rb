module LL
  ##
  # The Compiler class processes an AST (as parsed from an LL(1) grammar) and
  # returns an {LL::CompiledParser} instance containing details such as the
  # parsing states, callback method names, etc.
  #
  class Compiler
    ##
    # @param [LL::AST::Node] ast
    # @return [LL::CompiledParser]
    #
    def compile(ast)
      compiled = CompiledParser.new

      process(ast, compiled)

      warn_for_unused_terminals(compiled)
      warn_for_unused_rules(compiled)

      return compiled
    end

    ##
    # @param [LL::AST::Node] node
    # @param [LL::CompiledParser] compiled_parser
    # @return [LL::CompiledParser]
    #
    def process(node, compiled_parser)
      handler = "on_#{node.type}"

      return send(handler, node, compiled_parser)
    end

    ##
    # Processes the root node of a grammar.
    #
    # @param [LL::AST::Node] node
    # @param [LL::CompiledParser] compiled_parser
    #
    def on_grammar(node, compiled_parser)
      # Create the prototypes for all rules since rules can be referenced before
      # they are defined.
      node.children.each do |child|
        if child.type == :rule
          on_rule_prototype(child, compiled_parser)
        end
      end

      node.children.each do |child|
        process(child, compiled_parser)
      end
    end

    ##
    # Adds warnings for any unused rules. The first defined rule is skipped
    # since it's the root rule.
    #
    # @param [LL::CompiledParser] compiled_parser
    #
    def warn_for_unused_rules(compiled_parser)
      compiled_parser.rules.each_with_index do |rule, index|
        next if index == 0 || rule.references > 0

        compiled_parser.add_warning(
          "Unused rule #{rule.name.inspect}",
          rule.source_line
        )
      end
    end

    ##
    # Adds warnings for any unused terminals.
    #
    # @param [LL::CompiledParser] compiled_parser
    #
    def warn_for_unused_terminals(compiled_parser)
      compiled_parser.terminals.each do |terminal|
        next if terminal.references > 0

        compiled_parser.add_warning(
          "Unused terminal #{terminal.name.inspect}",
          terminal.source_line
        )
      end
    end

    ##
    # Sets the name of the parser.
    #
    # @param [LL::AST::Node] node
    # @param [LL::CompiledParser] compiled_parser
    #
    def on_name(node, compiled_parser)
      if compiled_parser.name
        compiled_parser.add_warning(
          "Overwriting existing parser name #{compiled_parser.name.inspect}",
          node.source_line
        )
      end

      parts = node.children.map { |child| process(child, compiled_parser) }

      compiled_parser.name = parts.join('::')
    end

    ##
    # Processes the assignment of terminals.
    #
    # @see #process
    #
    def on_terminals(node, compiled_parser)
      node.children.each do |child|
        name = process(child, compiled_parser)

        if compiled_parser.has_terminal?(name)
          compiled_parser.add_error(
            "The terminal #{name.inspect} has already been defined",
            child.source_line
          )
        else
          compiled_parser.add_terminal(name, child.source_line)
        end
      end
    end

    ##
    # Processes an %inner directive.
    #
    # @see #process
    #
    def on_inner(node, compiled_parser)
      compiled_parser.inner = process(node.children[0], compiled_parser)
    end

    ##
    # Processes a %header directive.
    #
    # @see #process
    #
    def on_header(node, compiled_parser)
      compiled_parser.header = process(node.children[0], compiled_parser)
    end

    ##
    # Processes a node containing Ruby source code.
    #
    # @see #process
    # @return [String]
    #
    def on_ruby(node, compiled_parser)
      return node.children[0]
    end

    ##
    # Extracts the name from an identifier.
    #
    # @see #process
    # @return [String]
    #
    def on_ident(node, compiled_parser)
      return node.children[0]
    end

    ##
    # Processes an epsilon.
    #
    # @see #process
    # @return [LL::Epsilon]
    #
    def on_epsilon(node, compiled_parser)
      return Epsilon.new(node.source_line)
    end

    ##
    # Processes the assignment of a rule.
    #
    # @see #process
    #
    def on_rule(node, compiled_parser)
      name = process(node.children[0], compiled_parser)

      if compiled_parser.has_rule_with_branches?(name)
        compiled_parser.add_error(
          "The rule #{name.inspect} has already been defined",
          node.source_line
        )

        return
      end

      branches = node.children[1..-1].map do |child|
        process(child, compiled_parser)
      end

      rule = compiled_parser.lookup_rule(name)

      rule.branches.concat(branches)
    end

    ##
    # Creates a basic prototype for a rule.
    #
    # @see #process
    #
    def on_rule_prototype(node, compiled_parser)
      name = process(node.children[0], compiled_parser)

      return if compiled_parser.has_rule?(name)

      rule = Rule.new(name, node.source_line)

      compiled_parser.add_rule(rule)
    end

    ##
    # Processes a single rule branch.
    #
    # @see #process
    # @return [LL::Branch]
    #
    def on_branch(node, compiled_parser)
      steps = process(node.children[0], compiled_parser)

      if node.children[1]
        code = process(node.children[1], compiled_parser)
      else
        code = nil
      end

      return Branch.new(steps, code)
    end

    ##
    # Processes the steps of a branch.
    #
    # @see #process
    # @return [Array]
    #
    def on_steps(node, compiled_parser)
      steps = []

      node.children.each do |step_node|
        retval = process(step_node, compiled_parser)

        # Literal rule/terminal names.
        if retval.is_a?(String)
          step = compiled_parser.lookup_identifier(retval)

          undefined_identifier!(retval, step_node, compiled_parser) unless step
        # Operators/epsilon
        else
          step = retval
        end

        # In case of an undefined terminal/rule (either on its own or inside an
        # operator).
        if step
          step.increment_references if step.respond_to?(:increment_references)

          steps << step
        end
      end

      return steps
    end

    ##
    # Processes the kleene star operator. This method expands the operator into
    # a set of anonymous rules and returns the start rule.
    #
    # This method turns this:
    #
    #     x = y*;
    #
    # Into this:
    #
    #     x  = y1;
    #     y1 = y2 | _;
    #     y2 = y y1;
    #
    # @see #process
    # @return [LL::Rule]
    #
    def on_star(node, compiled_parser)
      receiver = operator_receiver(node, compiled_parser)

      return unless receiver

      receiver.increment_references

      rule1 = Rule.new("_#{receiver.name}1", node.source_line)
      rule2 = Rule.new("_#{receiver.name}2", node.source_line)
      eps   = Epsilon.new(node.source_line)

      rule1.add_branch([rule2])
      rule1.add_branch([eps])

      rule2.add_branch([receiver, rule1])

      return rule1
    end

    ##
    # Processes the + operator.
    #
    # This turns this:
    #
    #     x = y+;
    #
    # Into this:
    #
    #     x  = y1;
    #     y1 = y y2;
    #     y2 = y1 | _;
    #
    # @see #process
    # @return [LL::Rule]
    #
    def on_plus(node, compiled_parser)
      receiver = operator_receiver(node, compiled_parser)

      return unless receiver

      receiver.increment_references

      rule1 = Rule.new("_#{receiver.name}1", node.source_line)
      rule2 = Rule.new("_#{receiver.name}2", node.source_line)
      eps   = Epsilon.new(node.source_line)

      rule1.add_branch([receiver, rule2])
      rule2.add_branch([rule1, eps])

      return rule1
    end

    ##
    # Processes the ? operator.
    #
    # This turns this:
    #
    #     x = y?;
    #
    # Into this:
    #
    #     x  = y1;
    #     y1 = y | _;
    #
    # @see #process
    # @return [LL::Rule]
    #
    def on_question(node, compiled_parser)
      receiver = operator_receiver(node, compiled_parser)

      return unless receiver

      receiver.increment_references

      rule1 = Rule.new("_#{receiver.name}1", node.source_line)
      eps   = Epsilon.new(node.source_line)

      rule1.add_branch([receiver])
      rule1.add_branch([eps])

      return rule1
    end

    private

    ##
    # @param [String] name
    # @param [LL::AST::Node] node
    # @param [LL::CompiledParser] compiled_parser
    #
    def undefined_identifier!(name, node, compiled_parser)
      compiled_parser.add_error(
        "Undefined terminal or rule #{name.inspect}",
        node.source_line
      )
    end

    ##
    # @param [LL::AST::Node] node
    # @param [LL::CompiledParser] compiled_parser
    # @return [LL::Rule|LL::Terminal|NilClass]
    #
    def operator_receiver(node, compiled_parser)
      rec_node = node.children[0]
      rec_name = process(rec_node, compiled_parser)
      receiver = compiled_parser.lookup_identifier(rec_name)

      if receiver
        return receiver
      else
        undefined_identifier!(rec_name, rec_node, compiled_parser)

        return
      end
    end
  end # Compiler
end # LL
