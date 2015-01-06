module LL
  module AST
    ##
    # Class containing details of a single node in an LL grammar AST.
    #
    class Node < ::AST::Node
      ##
      # @return [LL::SourceLine]
      #
      attr_reader :source_line

      ##
      # @return [Array]
      #
      OPERATOR_TYPES = [:plus, :star, :question]

      ##
      # @return [TrueClass|FalseClass]
      #
      def operator?
        return OPERATOR_TYPES.include?(type)
      end
    end # Node
  end # AST
end # LL
