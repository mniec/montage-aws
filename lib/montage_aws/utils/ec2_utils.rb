require 'net/ssh'
require 'net/sftp'
require 'openssl'
require 'aws-sdk'

module MontageAWS
  module EC2Utils
    KEYPAIR_NAME = 'montage_key'
    SECURITY_GROUP_NAME = 'montage_security_group'

    def init_EC2(params)
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

      @priv_key_path = File.join(ENV['HOME'], '.ssh/montage_key.pem')
      @pub_key_path = File.join(ENV['HOME'], '.ssh/montage_key.pub')
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

        max_trials = 3

        @logger.puts "INFO: Instance is running, trying to connect to #{instance.ip_address}"

        begin
          session = @ssh.start(instance.ip_address, @ec2_config[:user_name], :keys => [@priv_key_path])
          setup_machine session
          @logger.puts "INFO: Executing #{command}"
          @logger.puts session.exec! command
          session.close()
          true
        rescue Timeout::Error, Errno::ECONNREFUSED, Errno::EHOSTUNREACH => err
          max_trials-=1
          if max_trials > 0
            @logger.puts "ERROR: #{err} retrying after 10s"
            sleep 10
            retry
          else
            @logger.puts "ERROR: #{err}"
          end
        rescue Net::SSH::AuthenticationFailed => err
          max_trials-=1
          if max_trials > 0
            @logger.puts("ERROR: AuthenticationFailed #{err} retrying after 10s")
            sleep 10
            retry 
          end
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
        dest_file = "/home/#{@ec2_config[:user_name]}/montage_aws-0.0.2.gem"
        #uploading from local drive
        sftp.upload!(@ec2_config[:montage_gem_file], dest_file) if File.exist? @ec2_config[:montage_gem_file]
        # uploading from ec2 instance 
        sftp.upload!(dest_file, dest_file) if File.exist? dest_file

        sftp.upload!(File.join(ENV['HOME'], ".montage_aws.yml"), "/home/#{@ec2_config[:user_name]}/.montage_aws.yml")

        # very secure ...
        sftp.upload!(@priv_key_path, "/home/#{@ec2_config[:user_name]}/.ssh/montage_key.pem")
        sftp.upload!(@pub_key_path, "/home/#{@ec2_config[:user_name]}/.ssh/montage_key.pub")
      end

      puts ssh_session.exec! "sudo gem install --no-ri --no-rdoc montage_aws-0.0.2.gem"
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
      File.exist? @priv_key_path
    end

    def setup_keys
      if key_files_exists?
        unless @ec2.key_pairs.map(&:name).include?(KEYPAIR_NAME)
          @logger.puts 'INFO: Imporing existing KeyPair'

          if File.exist?  @pub_key_path
            @ec2.key_pairs.import(KEYPAIR_NAME, File.read( @pub_key_path))
          else
            @logger.puts "ERROR: Cannot import keypair public kay doesnt exist"
          end
        end
      else
        begin
          @logger.puts 'INFO: Creating new KeyPair'
          key_pair = @ec2.key_pairs.create(KEYPAIR_NAME)
          File.open(@priv_key_path, "w") do |f|
            f.write(key_pair.private_key)
          end


          private_key = OpenSSL::PKey::RSA.new(key_pair.private_key)
          File.open( @pub_key_path, "w") do |f|
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
end