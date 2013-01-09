module MontageAWS
  class ActivityFactory < TaskFactory
    def from_worker_task(activity_task)
      klass = get_klass_or_fail!  activity_task.activity_type.name.to_sym
      klass.new(activity_task, params)
    end
  end
end