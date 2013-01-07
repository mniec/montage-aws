module MontageAWS
	class InfrastructureProvisioner
		def initialize params
			@swf = params[:swf]
      		@config = params[:config]
      		@task_factory = params[:tasks]
		end 

		def execute
			domain = @swf.domains[@config[:domain]] 
			
			domain.activity_tasks.poll(@config[:provision_task_list]) do |activity_task|
				@task_factory.from_provision_event(activity_task).execute
			end 
		end 
	end
end 