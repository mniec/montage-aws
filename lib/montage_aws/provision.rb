module MontageAWS
  class Provision
    def initialize params
      @swf = params[:swf]
      @config = params[:config]
    end
    
    def execute
      vsn = @config[:workflow_version]

      domain = @swf.domains.create(@config[:domain], 10)
      
      workflow = create_workflow(@config[:workflow_name], 
                                 vsn, 
                                 @config[:default_task_list], 
                                 domain)

      create_activity('provision', vsn, @config[:provision_task_list], domain)
      create_activity('project', vsn, @config[:compute_task_list], domain)
    end
    
    private
    
    def create_activity name, vsn, task_list, domain
      domain.activity_types.create(name,
                                   vsn,
                                   :default_task_list => task_list,
                                   :default_task_start_to_close_timeout => :none,
                                   :default_task_heartbeat_timeout => :none,
                                   :default_task_schedule_to_start_timeout => :none,
                                   :default_task_schedule_to_close_timeout => :none)
    end

    def create_workflow name, vsn, task_list, domain
      workflow_opts = { :default_task_list => task_list,
        :default_child_policy => :request_cancel,
        :default_task_start_to_close_timeout => 3600,
        :default_execution_start_to_close_timeout => 24 * 3600 }

      domain.workflow_types.create(name,
                                   vsn, 
                                   workflow_opts)      
    end
  end
end
