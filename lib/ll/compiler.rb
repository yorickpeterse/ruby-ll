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
      # TODO
    end
  end # Compiler
end # LL
