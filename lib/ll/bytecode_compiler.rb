module LL
  ##
  # The Compiler class takes an AST and turns it into a set of bytecode
  # instructions. These instructions are in turn used to compile parsing tables.
  #
  class BytecodeCompiler
    ##
    # @param [LL::AST::Node] ast
    # @return [LL::CompiledParser]
    #
    def compile(ast)
      # TODO
    end
  end # BytecodeCompiler
end # LL
