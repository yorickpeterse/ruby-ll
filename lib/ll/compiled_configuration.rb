module LL
  ##
  # Class for storing the compiled state/lookup/action tables and the likes.
  #
  class CompiledConfiguration
    attr_reader :terminals, :rules, :table, :actions, :action_bodies

    ##
    # @param [Hash] options
    #
    # @option options [Array] :terminals
    # @option options [Array] :rules
    # @option options [Array] :table
    # @option options [Array] :actions
    # @option options [Hash] :action_bodies
    #
    def initialize(options = {})
      options.each do |key, value|
        instance_variable_set("@#{key}", value) if respond_to?(key)
      end

      @terminals     ||= []
      @rules         ||= []
      @table         ||= []
      @actions       ||= []
      @action_bodies ||= {}
    end
  end # CompiledConfiguration
end # LL
