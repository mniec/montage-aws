module MontageAWS
  class Compute < CmdTask
    DEF_MACHINES=2

    def execute
      validate

      @machines = options[:machines].nil? ? DEF_MACHINES : options[:machines]

      d = @swf.domains[config[:domain]]
      wf = d.workflow_types[config[:workflow_name], config[:workflow_version]]
      wf.start_execution :input => "#{@params[0]} #{@params[1]} #{@params[2]} #{@params[3]} #{@machines}"
    end

    private

    def validate
      error_msg = "Wrong cords '#{@params[0]} #{@params[1]}' #{@params[2]} #{@params[3]}"
      raise error_msg if @params.size != 4
      raise error_msg unless @params.all? { |p| p =~ /\d+/ }

      if !@options[:machines].nil? && !@options[:machines] =~ /\d+/
        raise "Machines param #{@options[:machines]} is wrong"
      end
    end


  end
end