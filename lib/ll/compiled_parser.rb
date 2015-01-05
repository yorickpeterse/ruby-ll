module LL
  ##
  # The CompiledParser class contains compilation results such as the parser
  # name, the parsing tables, etc.
  #
  class CompiledParser
    attr_accessor :name, :warnings, :errors, :terminals

    def initialize
      @warnings  = []
      @errors    = []
      @terminals = {}
      @rules     = {}
    end

    ##
    # @param [String] message
    # @param [LL::SourceLine] source_line
    #
    def add_error(message, source_line)
      @errors << Message.new(:error, message, source_line)
    end

    ##
    # @param [String] message
    # @param [LL::SourceLine] source_line
    #
    def add_warning(message, source_line)
      @warnings << Message.new(:warning, message, source_line)
    end

    ##
    # @param [String] name
    # @return [TrueClass|FalseClass]
    #
    def has_terminal?(name)
      return @terminals.key?(name)
    end

    ##
    # @param [String] name
    # @param [LL::SourceLine] source_line
    #
    def add_terminal(name, source_line)
      @terminals[name] = Terminal.new(name, source_line)
    end

    ##
    # Returns true if a rule for the given name has already been assigned.
    #
    # Since the input grammar can contain rule references before they are
    # assigned this method _only_ treats a rule as existing when:
    #
    # 1. The rule exists
    # 2. The rule has 1 or more branches
    #
    # This allows for grammars such as the following:
    #
    #     x = y
    #     y = T_SOMETHING
    #
    # @param [String] name
    # @return [TrueClass|FalseClass]
    #
    def has_rule?(name)
      return @rules.key?(name) && !@rules[name].branches.empty?
    end

    ##
    # @param [LL::Rule] rule
    #
    def add_rule(rule)
      @rules[rule.name] = rule
    end

    ##
    # @return [TrueClass|FalseClass]
    #
    def valid?
      return @errors.empty?
    end

    ##
    # Displays all warnings and errors.
    #
    def display_messages
      [:errors, :warnings].each do |type|
        send(type).each do |msg|
          output.puts(msg.to_s)
        end
      end
    end

    ##
    # @return [IO]
    #
    def output
      return STDERR
    end
  end # CompiledParser
end # LL
