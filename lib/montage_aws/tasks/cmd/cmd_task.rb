module MontageAWS
  class CmdTask < Task
    attr_reader :params, :options, :task_factory

    def initialize args
      super

      @params = args[:params]
      @options = args[:options]
      @task_factory = args[:task_factory]
    end

    def info msg
      logger.puts "INFO: #{msg}"
    end

  end
end