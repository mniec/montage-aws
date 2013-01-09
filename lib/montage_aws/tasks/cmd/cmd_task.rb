module MontageAWS
  class CmdTask < Task
    attr_reader :params, :options

    def initialize args
      super

      @params = args[:params]
      @options = args[:options]
    end

    def info msg
      logger.puts "INFO: #{msg}"
    end

  end
end