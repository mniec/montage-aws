module MontageAWS
  class ActivityTask < Task
    attr_reader :activity_task
    def initialize task, args
      super args
      @activity_task = task
    end
  end
end