module MontageAWS
  class Decider

    def initialize params
      @swf = params[:swf]
      @config = params[:config]
      @tasks = params[:tasks]
      @logger = params[:logger].nil? ? $stderr : params[:logger]
      @montage_helper = params[:montage_helper]
    end

    def execute
      domain_name = @config[:domain]
      def_task_list = @config[:default_task_list]

      info "Started"
      @swf.domains[domain_name].decision_tasks.poll(def_task_list) do |task|
        handle_task task
      end
    end

    def handle_task task
      info task.inspect
      task.new_events.each do |event|
        info "Event: #{event.inspect}"
        case event.event_type
        when 'WorkflowExecutionStarted'
          handle_workflow_start event, task
        end
      end
      task.complete!
    end

    def handle_workflow_start event, task
      params = event.attributes[:input].split(" ")
      x,y,h,w = params[0..3].map { |x| x.to_f }
      machines = params.last.to_i
      vsn  = @config[:workflow_version]
      1.upto(machines) do
        task.schedule_activity_task({:name => "provision", :version => vsn})
      end
      file_groups = @montage_helper.divide(x, y, h, w, machines)
      file_groups.each do |f|
        task.schedule_activity_task({:name => "project", :version => vsn}, :input => f)
      end
    end

    private

    def info message
      @logger.puts "INFO: #{message.to_s}"
    end

  end
end
