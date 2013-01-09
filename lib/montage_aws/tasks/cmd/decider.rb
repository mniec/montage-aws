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
          when 'ActivityTaskCompleted'
            handle_activity_completed event, task
        end
      end
      task.complete!
    end

    def handle_workflow_start event, task
      params = event.attributes[:input].split(" ")
      x, y, h, w = params[0..3].map { |x| x.to_f }
      machines = params.last.to_i
      vsn = @config[:workflow_version]
      1.upto(machines) do
        task.schedule_activity_task({:name => "provision", :version => vsn})
      end
      file_groups = @montage_helper.divide(x, y, h, w, machines)
      file_groups.each do |f|
        task.schedule_activity_task({:name => "project", :version => vsn}, :input => "#{x} #{y} #{h} #{w}\n#{f}")
      end
    end


    def get_state task
      state = {
          :input => {},
          :project_tasks => {},
          :provision_tasks => {},
          :merge_tasks => {},
          :merge_files => "",
          :output => ""
      }

      task.events.each do |e|
        case e.event_type
          when "WorkflowExecutionStarted"
            state[:input] = e.attributes[:input]
          when "ActivityTaskScheduled"
            case e.attributes[:activity_type].name
              when "project"
                state[:project_tasks][e.event_id] = false
              when "merge"
                state[:merge_tasks][e.event_id] = false
            end
          when "ActivityTaskCompleted"
            id = e.attributes[:scheduled_event_id]
            if state[:project_tasks].has_key? id
              state[:project_tasks][id] = true
              state[:merge_files] << e.attributes[:result]
              state[:merge_files] << "\n"
            elsif state[:merge_tasks].has_key? id
              state[:merge_tasks][id] = true
              state[:output] = e.attributes[:result]
            end
        end
      end
      state
    end

    def handle_activity_completed event, task
      state = get_state task
      if not state[:output].empty?
        task.complete_workflow_execution :result => state[:output]
      elsif state[:project_tasks].all? { |t| t } && state[:merge_tasks].size == 0
        schedule_merge state[:input], state[:merge_files], task
      end
    end

    def schedule_merge input, files, task
      params = input.split(" ")
      x, y, h, w = params[0..3].map { |x| x.to_f }
      vsn = @config[:workflow_version]
      task.schedule_activity_task({:name => "merge", :version => vsn},
                                  :input => "#{x} #{y} #{h} #{w}\n#{files}")
    end

    private

    def info message
      @logger.puts "INFO: #{message.to_s}"
    end

  end
end
