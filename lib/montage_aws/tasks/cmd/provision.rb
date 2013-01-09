module MontageAWS
  class Provision < CmdTask

    def execute
      vsn = @config[:workflow_version]

      domain = @swf.domains.create(@config[:domain], 10)

      workflow = create_workflow(@config[:workflow_name],
                                 vsn,
                                 @config[:default_task_list],
                                 domain)

      compute_task_list = @config[:compute_task_list]
      create_activity('provision', vsn, @config[:provision_task_list], domain)
      create_activity('project', vsn, compute_task_list, domain)
      create_activity('merge', vsn, compute_task_list, domain)

      bucket_name = @config[:s3_bucket]
      b = @s3.buckets[bucket_name]
      @s3.buckets.create(bucket_name) unless b.exists?

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
      workflow_opts = {:default_task_list => task_list,
                       :default_child_policy => :request_cancel,
                       :default_task_start_to_close_timeout => 3600,
                       :default_execution_start_to_close_timeout => 24 * 3600}

      domain.workflow_types.create(name,
                                   vsn,
                                   workflow_opts)
    end
  end
end
