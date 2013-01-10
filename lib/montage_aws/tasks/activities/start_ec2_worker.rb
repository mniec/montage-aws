module MontageAWS

  class StartEC2Worker < ActivityTask
    include EC2Utils

    def initialize task, params
      super task, params
      init_EC2 params
    end

    def execute
      @activity_task.record_heartbeat! :details=> "0%"
      
      start_and_execute_cmd("montage_aws start_worker -f ")
        
      @activity_task.record_heartbeat! :details=> "100%"
      @activity_task.complete!
    end
  end
end