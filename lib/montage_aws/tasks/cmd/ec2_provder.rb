module MontageAWS
  class EC2Provider < CmdTask

    def execute
      domain = swf.domains[config[:domain]]

      domain.activity_tasks.poll(config[:provision_task_list]) do |activity_task|
        task_factory.from_worker_task(activity_task).execute
      end
    end
  end
end 