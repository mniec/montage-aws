module MontageAWS
  class Worker

    def initialize params
      @swf = params[:swf]
      @config = params[:config]
      @tasks = params[:tasks]
      @logger = params[:logger].nil? ? $stderr : params[:logger]
    end
    
    def execute
      d = @swf.domains[@config[:domain]]
      d.activity_tasks.poll('compute-tasks') do |activ|
        task = @tasks.from_worker_task activ
        task.execute
      end
    end
    
  end
end
