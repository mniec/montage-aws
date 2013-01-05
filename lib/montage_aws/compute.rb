class Compute

  def initialize args
    @params = args[:params]
    @options = args[:options]
    @swf = args[:swf]
    @config = args[:config]
  end

  def execute
    validate
    
    d = @swf.domains[@config[:domain]]
    wf = d.workflow_types[@config[:workflow_name], @config[:workflow_version]]
    wf.start_execution :input => "#{@params[0]} #{@params[1]}"
  end
  
  private 
  
  def validate 
    error_msg = "Wrong cords '#{@params[0]} #{@params[1]}'"
    raise error_msg if @params.size != 2
    raise error_msg unless @params.all? { |p| p =~ /\d+/ }
  end
  
end
