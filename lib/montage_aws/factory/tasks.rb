module MontageAWS
  class Tasks
    attr_accessor :available_tasks, :params

    def initialize tasks, params
      self.class.validate! tasks
      @available_tasks = tasks
      @params = params
      @params[:tasks] = self
    end

    def self.validate! spec
      spec.each do |key,value|
        unless valid_task_name?(key)
          raise(ArgumentError, "Task name is not a symbol, #{key}") 
        end
        unless valid_task_class?(value)
          raise(ArgumentError, "Task doesn't have valid class associated with #{key}")
        end
      end
    end
    
    def self.validate spec
      spec.each {|k,v| return false unless valid_def(k, v) }
      true
    end

    def create_from_cmd cmd
      klass = @available_tasks[cmd.task]
      raise "No such task available" if klass.nil?
      args = { :params => cmd.params, :options => cmd.options }
      klass.new(args.merge(@params))
    end

    def from_decision_event event
      klass = @available_tasks[event.event_type.to_sym]
      raise "No such task available" if klass.nil?
      
      klass.new({:event => event}.merge(@params))
    end
    
    def from_worker_task activity_task
      klass = @available_tasks[activity_task.activity_type.name.to_sym]
      raise "No such task available" if klass.nil?
      
      klass.new({:activity_task => activity_task}.merge(@params))
    end
    
    private

    def self.valid_task_name? name
      name.class == Symbol
    end

    def self.valid_task_class? klass
      klass.class == Class
    end

    def self.valid_def key, val
      valid_task_name?(key) && valid_task_class?(val)
    end

  end
end
