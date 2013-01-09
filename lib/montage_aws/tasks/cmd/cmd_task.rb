module MontageAWS
  class CmdTask
    attr_reader :params, :options, :config, :logger, :task_factory, :swf, :s3, :montage

    def initialize args
      @params = args[:params]
      @options = args[:options]
      @config = args[:config]

      @logger = args[:logger].nil? ? $stderr : args[:logger]

      @task_factory = args[:tasks]
      @swf = args[:swf]
      @s3 = args[:s3]
      @montage = args[:montage]
    end

    def info msg
      logger.puts "INFO: #{msg}"
    end

  end
end