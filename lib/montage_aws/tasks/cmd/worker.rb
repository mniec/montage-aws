module MontageAWS
  class Worker

    def initialize params
      @swf = params[:swf]
      @config = params[:config]
      @tasks = params[:tasks]
      @logger = params[:logger].nil? ? $stderr : params[:logger]
    end

    def execute
      task_list = @config[:compute_task_list]
      d = @swf.domains[@config[:domain]]

      info "Starting to fetch tasks from #{task_list}"

      d.activity_tasks.poll(task_list) do |activ|
        info "Received task #{activ}"
        task = @tasks.from_worker_task activ
        task.execute
      end
    end

    def info msg
      @logger.puts "INFO: #{msg}"
    end
  end
end
