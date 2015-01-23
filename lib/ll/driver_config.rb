module LL
  ##
  # Class containing C/Java data for a Driver class.
  #
  class DriverConfig
    attr_reader :tokens, :rules, :table, :actions

    def tokens=(hash)
      self.tokens_native = @tokens = hash
    end

    def rules=(array)
      self.rules_native = @rules = array
    end

    def table=(array)
      self.table_native = @table = array
    end

    def actions=(array)
      self.actions_native = @actions = array
    end
  end # DriverConfig
end # LL
