require 'net/ssh'
require 'net/sftp'
require 'openssl'
require 'aws-sdk'

module MontageAWS
  class StartEc2 < ActivityTask
    KEYPAIR_NAME = 'montage_key'
    SECURITY_GROUP_NAME = 'montage_security_group'

    def initialize(task, params)
      super
      @ec2_config = params[:config][:ec2]

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
      setup_security_group
      setup_keys

      instance = find_stopped

      if instance.nil?
        instance = create_new
      else
        instance.start
      end

      unless instance.nil?

        sleep(@WAIT_TIME) until instance.status == :running

        max_trials = 2

        @logger.puts "INFO: Instance is running, trying to connect to #{instance.ip_address}"

        begin
          session = @ssh.start(instance.ip_address, @ec2_config[:user_name], :keys => [@ec2_config[:key_pair_priv]])
          setup_machine session
          @logger.puts "INFO: Executing #{command}"
          session.exec! command
          session.close()
        rescue Timeout::Error, Errno::ECONNREFUSED, Errno::EHOSTUNREACH => err
          max_trials-=1
          if max_trials > 0
            @logger.puts "ERROR: #{err} retrying after 10s"
            sleep 10
            retry
          else
            @logger.puts "ERROR: #{err}"
          end
        rescue Net::SSH::AuthenticationFailed
          @logger.puts("ERROR: AuthenticationFailed")
        end
      else
        @logger.puts 'ERROR: Cannot create instance'
      end
    end


    private

    # upload required files etc
    def setup_machine ssh_session
      @logger.puts "INFO: Uploading #{@ec2_config[:montage_gem_file]}"

      ssh_session.sftp.connect do |sftp|
        sftp.upload!(@ec2_config[:montage_gem_file], "/home/#{@ec2_config[:user_name]}/montage_aws-0.0.1.gem")
        sftp.upload!(File.join(ENV['HOME'], ".montage_aws.yml"), "/home/#{@ec2_config[:user_name]}/.montage_aws.yml")
      end

      puts ssh_session.exec! "sudo gem install --no-ri --no-rdoc montage_aws-0.0.1.gem"
    end

    def instance_valid? instance
      instance.image_id == @ec2_config[:ami_id] and instance.availability_zone == @ec2_config[:region] and instance.key_name == KEYPAIR_NAME
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
      @logger.puts 'INFO: Creating new microinstance from montage ami'

      #and finally create and start instance
      @ec2.instances.create(:image_id => @ec2_config[:ami_id],
                            :key_name => KEYPAIR_NAME,
                            :availability_zone => @ec2_config[:region],
                            :instance_type => @ec2_config[:instance_type],
                            :security_groups => [SECURITY_GROUP_NAME])
    end

    def key_files_exists?
      File.exist? @ec2_config[:key_pair_priv]
    end

    def setup_keys
      if key_files_exists?
        unless @ec2.key_pairs.map(&:name).include?(KEYPAIR_NAME)
          @logger.puts 'INFO: Imporing existing KeyPair'

          if File.exist? @ec2_config[:key_pair_pub]
            @ec2.key_pairs.import(KEYPAIR_NAME, File.read(@ec2_config[:key_pair_pub]))
          else
            @logger.puts "ERROR: Cannot import keypair public kay doesnt exist"
          end
        end
      else
        begin
          @logger.puts 'INFO: Creating new KeyPair'
          key_pair = @ec2.key_pairs.create(KEYPAIR_NAME)
          File.open(@ec2_config[:key_pair_priv], "w") do |f|
            f.write(key_pair.private_key)
          end


          private_key = OpenSSL::PKey::RSA.new(key_pair.private_key)
          File.open(@ec2_config[:key_pair_pub], "w") do |f|
            f.write private_key.public_key.to_pem
          end

        rescue AWS::EC2::Errors::InvalidKeyPair::Duplicate
          kp = @ec2.key_pairs.find do |kp|
            kp.name == KEYPAIR_NAME
          end
          @logger.puts 'INFO: KeyPair already exist deleting'
          #delete all instances using old key
          @ec2.instances.each do |i|
            if i.key_name == KEYPAIR_NAME
              @logger.puts "INFO: Terminating instance: #{i.id} (uses invalid keypair)"
              i.terminate
            end
          end
          kp.delete
          retry
        end

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

    def initialize task, params
      super
    end

    def execute
      start_and_execute_cmd "montage_aws start_ec2_provisioner -f "
    end
  end

  class StartEC2Worker <StartEc2
    def initialize task, params
      super
    end

    def execute
      start_and_execute_cmd "montage_aws start -f "
    end
  end

  class StartEC2Decider <StartEc2
    def initialize task, params
      super
    end

    def execute
      start_and_execute_cmd "montage_aws start_decider -f "
    end

  end
end