module LL
  ##
  # The CodeGenerator class takes a {LL::CompiledConfiguration} instance and
  # turns it into a block of Ruby source code that can be used as an actual
  # LL(1) parser.
  #
  class CodeGenerator
    ##
    # The ERB template to use for code generation.
    #
    # @return [String]
    #
    TEMPLATE = File.expand_path('../driver_template.erb', __FILE__)

    ##
    # @param [LL::CompiledConfiguration] config
    # @return [String]
    #
    def generate(config)
      context  = ERBContext.new(:config => config)
      template = File.read(TEMPLATE)
      erb      = ERB.new(template, nil, '-').result(context.get_binding)

      return erb
    end
  end # CodeGenerator
end # LL
