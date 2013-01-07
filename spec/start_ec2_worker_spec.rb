require 'spec_helper'

describe StartEC2Worker do
	before (:each) do 
		@ec2 = double('ec2')
		@ssh = double('ssh')
		@params = []
		@options = {}
		@config = double('config')
		@cf = double('cf')
		@cf.stub(:[]).with(:ec2){@config}
	end

	subject { StartEC2Worker.new  :params => @params, :options => @options, 
		:logger => $stderr, :config=>@cf, :ec2 => @ec2, :ssh => @ssh  }

	describe ".new" do 
		it "should accept params, options, config, logger" do
			subject.should_not be_nil
		end
	end 

	describe "#execute" do 
		it 'should create new ec2 worker instance and invoke command on it ' do 

		end 

		it 'should start ec2 worker instance and invoke command  on it ' do
			user_name ='ubuntu'
			ip = '10.0.0.1'

			@config.should_receive(:[]).with(:ami_id).and_return('ami-7542c01c')
			@config.should_receive(:[]).with(:key_pair).and_return('identity.pub')
			@config.should_receive(:[]).with(:region){'us-east-1a'}
			@config.should_receive(:[]).with(:user_name){user_name}



			instance = double('instance')
			instance.should_receive('start')
			instance.should_receive('ip_address'){ip}
			instance.should_receive('status'){:stopped}
			instance.should_receive('image_id'){'ami-7542c01c'}
			instance.should_receive('availability_zone'){'us-east-1a'}

			instances = double('instances')
			
			instances.should_receive('each') {|&arg| arg.call instance}

			@ec2.should_receive('instances') {instances}
		
			command = "montage_aws start"
			session = double('session')
			session.should_receive('exec').with(command)
			session.should_receive('close')

			@ssh.should_receive('start').with(ip,user_name,:keys => ['identity.pub']).and_return(session)

			
			subject.execute
		end
	end 
end 