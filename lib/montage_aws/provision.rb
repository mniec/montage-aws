module MontageAWS
  class Provision
    def initialize params
      @aws = params[:aws]
      @config = params[:config]
    end
    
    def execute
      swf = @aws.new
      vsn = @config[:workflow_version]

      domain = swf.domains.create(@config[:domain])
      
      workflow = create_workflow(@config[:workflow_name], 
                                 vsn, 
                                 @config[:default_task_list], 
                                 domain)

      create_activity('provision', vsn, 'provision-tasks', domain)
      create_activity('compute', vsn, 'compute-tasks', domain)
    end
    
    private
    
    def create_activity name, vsn, task_list, domain
      domain.activity_types.create(name,
                                   vsn,
                                   :default_task_list => task_list)
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
