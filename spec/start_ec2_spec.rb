require 'spec_helper'

describe StartEc2 do
	before (:each) do 
		@ec2 = double('ec2')
		@ssh = double('ssh')
		@params = []
		@options = {}
		@config = double('config')
		@cf = double('cf')
		@cf.stub(:[]).with(:ec2){@config}
	end

	subject { StartEc2.new  :params => @params, :options => @options, 
		:logger => $stderr, :config=>@cf, :ec2 => @ec2, :ssh => @ssh  }

	describe ".new" do 
		it "should accept params, options, config, logger" do
			subject.should_not be_nil
		end
	end 

	describe "#execute" do 
		it 'should create instance, import existing key_pair and execute command on it' do 

		end 

		it 'should  create new key_pair store it on disks, create new instance and execute command on it' do 
		end 

		it 'should find stopped instance, start it  and invoke command via ssh' do
			user_name ='ubuntu'
			ip = '10.0.0.1'

			@config.should_receive(:[]).with(:ami_id).and_return('ami-7542c01c')
			@config.should_receive(:[]).with(:key_pair_priv).and_return('identity.pem')
			@config.should_receive(:[]).with(:region){'us-east-1a'}
			@config.should_receive(:[]).with(:user_name).at_least(:once){user_name}
			@config.should_receive(:[]).with(:montage_gem_file).at_least(:once){'/home/pawel/Code/awscomp/montage.gem'}


			instance = double('instance')
			instance.should_receive('start')
			instance.should_receive('ip_address').at_least(:once){ip}
			instance.should_receive('status').and_return(:stopped,:stopped, :pending, :running)
			instance.should_receive('image_id'){'ami-7542c01c'}
			instance.should_receive('availability_zone'){'us-east-1a'}
			instance.should_receive('key_name'){'montage_key'}
			instance.should_receive('id'){'i-123812'}

			instances = double('instances')
			
			instances.should_receive('each') {|&arg| arg.call instance}

			@ec2.should_receive('instances') {instances}
		
			sftp = double('sftp')
			sftp.should_receive('upload!').twice

			sftp.should_receive('connect') do |&c| 
				c.call sftp
			end 

			install_gem_cmd = "sudo gem install --no-ri --no-rdoc montage_aws-0.0.1.gem"
			command = "montage_aws start_decider"

			session = double('session')
			session.should_receive('exec!').with(install_gem_cmd)
			session.should_receive('exec!').with(command)
			session.should_receive('close')
			session.should_receive('sftp'){sftp}

			@ssh.should_receive('start').with(ip,user_name,:keys => ['identity.pem']).and_return(session)

			
			subject.start_and_execute_cmd command
		end
	end 
end 
