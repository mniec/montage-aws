module MontageAWS
  class Decider
    def initialize params
      @swf = params[:swf]
      @config = params[:config]
      @tasks = params[:tasks]
    end
    
    def execute
      @swf.domains[@config[:domain]].decision_tasks.poll(@config[:default_task_list]) do |task|
        execute_task task
      end
    end
    
    def execute_task task
      task.new_events.each do |event|
        task = @tasks.from_decision_event event
        task.execute
      end
    end
  end
end
