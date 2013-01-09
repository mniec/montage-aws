module MontageAWS
  
  class Cmd
    ARG_PAT=/\-\-?(\w+)/

    attr_accessor :task, :params, :options

    def initialize args
      # set task name (first option passed)
      @task = (args.shift).to_sym if args_valid? args

      # set task params (options without -- passed after first arg)
      @params = []
      while is_first_param? args
        @params << args.shift.strip
      end
      
      # parse rest options
      @options = {}
      parse @options, args
    end
   
    private 
    
    def parse hash, args
      return hash if args.nil? || args.empty? 
      arg = args.shift.strip

      _, id = *ARG_PAT.match(arg)
      id = id.to_sym

      if is_first_param? args
        hash[id] = args.shift.strip
        if is_first_param? args
          hash[id] = [hash[id]]
          hash[id] << args.shift.strip while is_first_param? args
        end
      else
        hash[id] = true
      end

      if args.length > 0
        parse hash, args 
      else
        hash
      end
    end

    def is_first_param? args
      ! (args.empty? || args.first =~ ARG_PAT)
    end
    
    def args_valid? args
      !args.nil? && !args.empty?
    end

  end
end
