module MontageAWS
  class CmdFactory < TaskFactory
    attr_reader :task_factory
    def initialize(activity_factory, tasks, params)
      super tasks, params
      params[:task_factory] = activity_factory
    end

    def create_from_cmd(cmd)
      klass = get_klass_or_fail! cmd.task
      args = {:params => cmd.params, :options => cmd.options}
      klass.new(args.merge(params))
    end
  end
end