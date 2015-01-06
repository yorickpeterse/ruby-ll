module LL
  ##
  # Class containing details of a single rule in a grammar.
  #
  class Rule
    attr_reader :name, :branches, :source_line, :references

    ##
    # @param [String] name
    # @param [LL::SourceLine] source_line
    #
    def initialize(name, source_line)
      @name        = name
      @branches    = []
      @source_line = source_line
      @references  = 0
    end

    def add_branch(steps, ruby_code = nil)
      branches << Branch.new(steps, ruby_code)
    end

    def increment_references
      @references += 1
    end

    def inspect
      return "Rule(name: #{@name.inspect}, branches: #{@branches.inspect})"
    end
  end # Rule
end # LL
