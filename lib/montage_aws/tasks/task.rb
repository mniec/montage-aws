module MontageAWS
  class Task
    attr_reader :config, :logger, :task_factory, :swf, :ec2, :s3, :montage

    def initialize args
      @config = args[:config]

      @logger = args[:logger].nil? ? $stderr : args[:logger]

      @task_factory = args[:tasks]
      @swf = args[:swf]
      @s3 = args[:s3]
      @ec2 = args[:ec2]
      @montage = args[:montage]
    end
  end
end
