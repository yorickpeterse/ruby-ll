module LL
  class Driver
    T_EOF = -1
    T_RULE = 0
    T_TERMINAL = 1
    T_EPSILON = 2
    T_ACTION = 3
    T_STAR = 4
    T_PLUS = 5
    T_ADD_VALUE_STACK = 6
    T_APPEND_VALUE_STACK = 7
    T_QUESTION = 8

    def config
      self.class::CONFIG
    end

    def parse
      stack = []
      value_stack = []

      # EOF
      stack << T_EOF << T_EOF

      # Start rule
      start_row = config.rules_native[0]
      stack += start_row

      # Each token
      each_token do |type, value|
        loop do
          if stack.empty?
            parser_error(-1, -1, type, value)
          end

          stack_value = stack.pop
          stack_type  = stack.pop
          token_id    = config.terminals_native[type] || 0

          # A rule or the "+" operator
          if stack_type == T_RULE || stack_type == T_PLUS
            production_i = config.table_native[stack_value][token_id] || T_EOF

            if production_i == T_EOF
              parser_error(stack_type, stack_value, type, value)
            else
              # Append a "*" operator for all following occurrences as they are optional
              if stack_type == T_PLUS
                stack << T_STAR << stack_value
                stack << T_APPEND_VALUE_STACK << 0
              end

              row = config.rules_native[production_i]
              stack += row
            end
          # "*" operator
          elsif stack_type == T_STAR
            production_i = config.table_native[stack_value][token_id] || T_EOF

            if production_i != T_EOF
              stack << T_STAR << stack_value
              stack << T_APPEND_VALUE_STACK << 0

              row = config.rules_native[production_i]
              stack += row
            end
          # "?" operator
          elsif stack_type == T_QUESTION
            production_i = config.table_native[stack_value][token_id] || T_EOF

            if production_i == T_EOF
              value_stack << nil
            else
              row = config.rules_native[production_i]
              stack += row
            end
          # Adds a new array to the value stack that can be used to group operator values together
          elsif stack_type == T_ADD_VALUE_STACK
            operator_buffer = []
            value_stack << operator_buffer
          # Appends the last value on the value stack to the operator buffer that precedes it.
          elsif stack_type == T_APPEND_VALUE_STACK
            last_value      = value_stack.pop
            operator_buffer = value_stack.last
            operator_buffer << last_value
          # Terminal
          elsif stack_type == T_TERMINAL
            if stack_value == token_id
              value_stack << value
              break
            else
              parser_error(stack_type, stack_value, type, value)
            end
          # Action
          elsif stack_type == T_ACTION
            method = config.action_names_native[stack_value].to_s
            num_args = config.action_arg_amounts_native[stack_value]
            action_args = Array.new(num_args)

            num_args = [num_args, value_stack.size].min
            while num_args > 0
              num_args -= 1
              action_args[num_args] = value_stack.pop if value_stack.size > 0
            end

            value_stack << self.send(method, action_args)
          elsif stack_type == T_EOF
            break
          end
        end
      end

      value_stack.empty? ? nil : value_stack.pop
    end
  end
end
