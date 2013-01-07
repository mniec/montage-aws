require 'net/ssh'
require 'net/sftp'

module MontageAWS
    class StartEc2
        KEYPAIR_NAME = 'montage_key'
        SECURITY_GROUP_NAME = 'montage_security_group'

        def initialize params
            @ec2 = params[:ec2]
            @swf = params[:swf]
            @config = params[:config][:ec2]
            @logger = params[:logger]

            if params[:ssh].nil?
                @ssh = Net::SSH
                @sftp = Net::SFTP
                @WAIT_TIME = 2
            else #for testing 
                @sftp = params[:sftp]
                @ssh = params[:ssh]
                @WAIT_TIME = 0 
            end 
        end 

        def start_and_execute_cmd command 
            instance = find_stopped
            
            if instance.nil? 
                instance = create_new
            else
                instance.start 
            end
            
            unless instance.nil?
                sleep(@WAIT_TIME) until instance.status == :running
                
                max_trials = 3

                @logger.puts "INFO: Instance is running, trying to connect to #{instance.ip_address}"

                begin 
                    session = @ssh.start(instance.ip_address,@config[:user_name],:keys => [@config[:key_pair_priv]])

                    setup_machine session

                    @logger.puts "INFO: Executing #{command}"

                    puts session.exec! command
                    session.close() 
                rescue Exception => err  

                    max_trials-=1
                    if max_trials > 0 
                        @logger.puts "ERROR: #{err} retrying after 10s"
                        sleep 10 
                        retry
                    else 
                        @logger.puts "ERROR: #{err}"
                    end 
                end 
            else
                @logger.puts 'ERROR: Cannot create instance'
            end 
        end


        private 

        # upload required files etc
        def setup_machine ssh_session
            @logger.puts "INFO: Uploading #{@config[:montage_gem_file]}"

            ssh_session.sftp.connect do |sftp|
                sftp.upload!(@config[:montage_gem_file], "/home/#{@config[:user_name]}/montage_aws-0.0.1.gem") 
                sftp.upload!("/home/pawel/.montage_aws.yml", "/home/#{@config[:user_name]}/.montage_aws.yml")
            end 

            puts ssh_session.exec! "sudo gem install --no-ri --no-rdoc montage_aws-0.0.1.gem"
       end 

       def instance_valid? instance
        instance.image_id == @config[:ami_id] and instance.availability_zone == @config[:region]  and instance.key_name == KEYPAIR_NAME
    end 

    def find_stopped
        @ec2.instances.each do |i|
            if i.status == :stopped and instance_valid?(i)
                @logger.puts "INFO: #{i.id} found"
                return i
            end 
        end 

        @logger.puts 'INFO: No valid montage instance found. Trying to create new one.'
    end 

    def create_new

        setup_security_group
        setup_keys

        @logger.puts 'INFO: Creating new microinstance from montage ami'

            #and finally create and start instance     
            @ec2.instances.create(:image_id => @config[:ami_id], 
               :key_name => KEYPAIR_NAME,
               :availability_zone => @config[:region],
               :instance_type => @config[:instance_type],
               :security_groups => [SECURITY_GROUP_NAME] )
        end     

        def key_files_exists?
            File.exist? @config[:key_pair_pub] and File.exist? @config[:key_pair_priv]
        end 

        def setup_keys
            if key_files_exists?
                unless @ec2.key_pairs.map(&:name).include?(KEYPAIR_NAME)
                    @logger.puts 'INFO: Imporing existing KeyPair'
                    @ec2.key_pairs.import(KEYPAIR_NAME,File.read(@config[:key_pair_pub]) )
                end
            else
                @logger.puts 'INFO: Creating new KeyPair'
                key_pair = ec2.key_pairs.create(KEYPAIR_NAME)
                File.open(@config[:key_pair_priv], "w") do |f|
                    f.write(key_pair.private_key)
                end
                # TODO generate public key
            end
        end

        def setup_security_group
            unless @ec2.security_groups.map(&:name).include?(SECURITY_GROUP_NAME)
                @logger.puts 'INFO: Creating Montage security group'
                g = @ec2.security_groups.create(SECURITY_GROUP_NAME)
                g.authorize_ingress :tcp, 22
                g.allow_ping
            end
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