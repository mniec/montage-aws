module MontageAWS
  class CmdTask

    def initialize args
      @params = args[:params]
      @options = args[:options]
      @config = args[:config]

      @logger = args[:logger].nil? ? $stderr : args[:logger]

      @task_factory = args[:tasks]
      @swf = args[:swf]
      @config = args[:config]
      @s3 = args[:s3]
      @montage_helper = args[:montage_helper]
    end

    def info msg
      @logger.puts "INFO: #{msg}"
    end

  end
end