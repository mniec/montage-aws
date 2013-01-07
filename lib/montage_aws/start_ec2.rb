require 'net/ssh'

module MontageAWS
    class StartEc2

        def initialize params
            @ec2 = params[:ec2]
            @swf = params[:swf]
            @config = params[:config][:ec2]
            @logger = params[:logger]
            @ssh = params[:ssh]
            @ssh = Net::SSH  if params[:ssh].nil?

            @WAIT_TIME = 2 
            @WAIT_TIME = 0 unless params[:ssh].nil?

        end 

        def start_and_execute_cmd command 
            instance = find_stopped
            instance = create_new if instance.nil?
            
            unless instance.nil?
                instance.start

                sleep(@WAIT_TIME) until instance.status == :running

                #puts "#{@config[:user_name]}  and key #{@config[:key_pair]} on addr #{instance.ip_address}"
                session = @ssh.start(instance.ip_address,@config[:user_name],:keys => [@config[:key_pair]])
                puts session.exec! command
                session.close() 
            else
                #report error 
            end 
        end


        private 

        def instance_valid? instance
            ## TODO keypair
            instance.image_id == @config[:ami_id] and instance.availability_zone == @config[:region] 
        end 

        def find_stopped
            @ec2.instances.each do |i|
                if i.status == :stopped and instance_valid?(i)
                    return i
                end 
            end 

            nil
        end 

        def create_new
            nil
        end     


        def key_files_exists?
            false 
        end 

    end


    class StartEC2InfrastructureProvisioner < StartEc2

        def initialize params
            super(params)
        end 

        def execute
            start_and_execute_cmd "montage_aws start_ec2_provisioner"
        end 
    end 


    class StartEC2Worker  <StartEc2
        def initialize params
            super(params)
        end 

        def execute
            start_and_execute_cmd "montage_aws start"
        end
    end 

    class StartEC2Decider <StartEc2
        def initialize params
            super(params)
        end 

        def execute
            start_and_execute_cmd "montage_aws start_decider"
        end
    end
end