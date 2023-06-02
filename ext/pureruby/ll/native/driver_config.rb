module LL
  class DriverConfig
    attr_reader :terminals_native, :rules_native, :table_native,
                :action_names_native, :action_arg_amounts_native

    def initialize
      @terminals_native = {}
      @rules_native = []
      @table_native = []
      @action_names_native = []
      @action_arg_amounts_native = []
    end

    def terminals_native=(array)
      array.each_with_index do |sym, index|
        @terminals_native[sym] = index
      end
    end

    def rules_native=(array)
      array.each do |ruby_row|
        row = []
        ruby_row.each do |column|
          row << column.to_i
        end
        @rules_native << row
      end
    end

    def table_native=(array)
      array.each do |ruby_row|
        row = []
        ruby_row.each do |column|
          row << column.to_i
        end
        @table_native << row
      end
    end

    def actions_native=(array)
      array.each do |row|
        name, arity = row
        @action_names_native << name
        @action_arg_amounts_native << arity.to_i
      end
    end
  end
end
