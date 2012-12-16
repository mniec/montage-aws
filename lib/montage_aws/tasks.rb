module MontageAWS
  class Tasks
    attr_accessor :available_tasks

    def initialize tasks
      self.class.validate! tasks
      @available_tasks = tasks
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
      klass.new cmd.params, cmd.options
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
