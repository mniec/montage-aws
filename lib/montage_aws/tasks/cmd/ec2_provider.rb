module MontageAWS
  class EC2Provider < CmdTask

    def execute
      domain = swf.domains[config[:domain]]

      domain.activity_tasks.poll(config[:provision_task_list]) do |activity_task|
        task_factory.from_worker_task(activity_task).execute
      end
    end
  end


  class StartEC2DeciderAndProvider< CmdTask
    include EC2Utils

    def initialize args
      super
      init_EC2 args
    end

    def execute
      start_and_execute_cmd "montage_aws start_provider -f ;montage_aws start_decider -f "
    end
  end
end 