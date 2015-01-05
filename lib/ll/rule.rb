module LL
  ##
  # Class containing details of a single rule in a grammar.
  #
  class Rule
    attr_reader :name, :branches, :source_line

    ##
    # @param [String] name
    # @param [LL::SourceLine] source_line
    #
    def initialize(name, source_line)
      @name        = name
      @branches    = []
      @source_line = source_line
    end
  end # Rule
end # LL
