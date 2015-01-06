module LL
  ##
  # The Branch class contains information of a single rule branch such as the
  # steps and the associated callback code.
  #
  class Branch
    attr_reader :steps, :ruby_code

    ##
    # @param [Array] steps
    # @param [String] ruby_code
    #
    def initialize(steps, ruby_code = nil)
      @steps     = steps
      @ruby_code = ruby_code
    end

    def inspect
      code = @ruby_code ? '...' : nil

      return "Branch(steps: #{@steps.inspect}, ruby_code: #{code.inspect})"
    end
  end # Branch
end # LL
