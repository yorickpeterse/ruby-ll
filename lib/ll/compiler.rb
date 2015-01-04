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
          "Overwriting existing parser name #{compiled_parser.name}",
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
            "Attempt to redefine existing terminal #{name.inspect}",
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

    end
  end # Compiler
end # LL
