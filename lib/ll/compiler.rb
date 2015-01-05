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
      node.children.each do |child|
        process(child, compiled_parser)
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
    # Extracts the name from an identifier.
    #
    # @see [#process]
    # @return [String]
    #
    def on_ident(node, compiled_parser)
      return node.children[0]
    end

    ##
    # Processes the assignment of terminals.
    #
    # @see [#process]
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
    # @see [#process]
    #
    def on_inner(node, compiled_parser)

    end

    ##
    # Processes a %header directive.
    #
    # @see [#process]
    #
    def on_header(node, compiled_parser)

    end

    ##
    # Processes the assignment of a rule.
    #
    # @see [#process]
    #
    def on_rule(node, compiled_parser)
      name = process(node.children[0], compiled_parser)

      if compiled_parser.has_rule?(name)
        compiled_parser.add_error(
          "The rule #{name} has already been defined",
          node.source_line
        )

        return
      end

      branches = node.children[1..-1].map do |child|
        process(child, compiled_parser)
      end
    end

    ##
    # Processes a single rule branch.
    #
    # @see [#process]
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
    # @see [#process]
    # @return [LL::Branch]
    #
    def on_steps(node, compiled_parser)
      node.children.each do |step|
        retval = process(step, compiled_parser)

        if retval.is_a?(String)

        else

        end
      end
    end

    ##
    # Processes the kleene star operator. This method expands the operator into
    # a set of anonymous rules and returns the start rule.
    #
    # @see [#process]
    # @return [LL::Rule]
    #
    def on_star(node, compiled_parser)
      receiver = process(node.children[0], compiled_parser)

    end
  end # Compiler
end # LL
