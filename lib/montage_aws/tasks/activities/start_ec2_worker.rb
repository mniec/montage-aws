module MontageAWS

  class StartEC2Worker < ActivityTask
    include EC2Utils

    def initialize task, params
      super
      init_EC2 params
    end

    def execute
      start_and_execute_cmd "montage_aws start_worker -f "
    end
  end
end