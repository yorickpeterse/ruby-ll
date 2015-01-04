module LL
  ##
  # Class containing details of a single terminal in a grammar.
  #
  class Terminal
    attr_reader :name, :source_line

    ##
    # @param [String] name
    # @param [LL::SourceLine] source_line
    #
    def initialize(name, source_line)
      @name        = name
      @source_line = source_line
    end
  end # Terminal
end # LL
