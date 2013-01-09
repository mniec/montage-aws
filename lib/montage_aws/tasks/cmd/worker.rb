module MontageAWS
  class Worker < CmdTask

    def execute
      task_list = @config[:compute_task_list]
      d = @swf.domains[@config[:domain]]

      info "Starting to fetch tasks from #{task_list}"

      d.activity_tasks.poll(task_list) do |activ|
        info "Received task #{activ}"
        task = @task_factory.from_worker_task activ
        task.execute
      end
    end

  end
end
