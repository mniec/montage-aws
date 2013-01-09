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
    @task = double('activity_task')
	end

	subject { StartEc2.new @task,	:logger => $stderr, :config=>@cf, :ec2 => @ec2, :ssh => @ssh  }

	describe ".new" do 
		it "should accept params, options, config, logger" do
			subject.should_not be_nil
		end
	end 

	describe "#execute" do 
		user_name ='ubuntu'
		ip = '10.0.0.1'
		command = "montage_aws start_decider"


		before :each do 
			@config.should_receive(:[]).with(:ami_id).and_return('ami-7542c01c')
			@config.should_receive(:[]).with(:key_pair_priv).at_least(:once).and_return('/home/pawel/ec2_identity.pem')
			@config.should_receive(:[]).with(:region){'us-east-1a'}
			@config.should_receive(:[]).with(:user_name).at_least(:once){user_name}
			@config.should_receive(:[]).with(:montage_gem_file).at_least(:once){'/home/pawel/Code/awscomp/montage.gem'}

			@instance = double('instance')
			@instance.should_receive('ip_address').at_least(:once){ip}
			

			@instances = double('instances')
			
		end 


		it 'should create instance, import existing key_pair and execute command on it' do 
			@config.should_receive(:[]).with(:key_pair_pub).and_return('/home/pawel/ec2_identity.pub')
			@config.should_receive(:[]).with(:instance_type).at_least(:once){'t1.micro'}

			@instance.should_receive('status'){:running}
			@instances.should_receive('each')

			security_groups = double('security_groups')
			#security_groups.should_receive('name')
			security_groups.should_receive('map'){['montage_security_group']}
			@ec2.should_receive('security_groups'){security_groups}

			key_pair = double('private_key')
			key_pair.should_receive('private_key')

			key_pairs = double('security_groups')
			key_pairs.should_receive('name')
			key_pairs.should_receive('map'){['another key']}
			key_pairs.should_receive('create').with('montage_key'){key_pair}
			@ec2.should_receive('key_pairs'){key_pairs}

			@instances.should_receive('create').with({:image_id=>"ami-7542c01c",
													  :key_name=>"montage_key",
													  :availability_zone=>"us-east-1a", 
													  :instance_type=>"t1.micro", 
													  :security_groups=>["montage_security_group"]}){@instance}

			@ec2.should_receive('instances').at_least(:once) {@instances}
		end 

		it 'should  create new key_pair store it on disks, create security group, create new instance and execute command on it' do
			@instance.should_receive('status'){:running}
			@instances.should_receive('each')
			@ec2.should_receive('instances') {@instances}
		end 

		it 'should find stopped instance, start it  and invoke command via ssh' do
			@instance.should_receive('image_id'){'ami-7542c01c'}
			@instance.should_receive('availability_zone'){'us-east-1a'}
			@instance.should_receive('key_name'){'montage_key'}
			@instance.should_receive('id'){'i-123812'}

			@instance.should_receive('status').and_return(:stopped,:stopped, :pending, :running)
			@instances.should_receive('each') {|&arg| arg.call @instance}
			@ec2.should_receive('instances') {@instances}
			@instance.should_receive('start')
		end


		after :each  do 
			sftp = double('sftp')
			sftp.should_receive('upload!').twice
			sftp.should_receive('connect') do |&c| 
				c.call sftp
			end 

			install_gem_cmd = "sudo gem install --no-ri --no-rdoc montage_aws-0.0.1.gem"
			
			session = double('session')
			session.should_receive('exec!').with(install_gem_cmd)
			session.should_receive('exec!').with(command)
			session.should_receive('close')
			session.should_receive('sftp'){sftp}

			@ssh.should_receive('start').with(ip,user_name,:keys => ['/home/pawel/ec2_identity.pem']).and_return(session)

			
			subject.start_and_execute_cmd command
		end 
	end 
end 
