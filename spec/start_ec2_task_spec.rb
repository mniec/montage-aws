require 'spec_helper'

describe StartEc2Task do
	before (:each) do 
		@ec2 = double('ec2')
		@ssh = double('ssh')
		@params = []
		@options = {}
		@config = double('config')
	end

	subject { StartEc2Task.new  :params => @params, :options => @options, 
		:logger => $stderr, :config=>@config, :ec2 => @ec2, :ssh => @ssh  }

	describe ".new" do 
		it "should accept params, options, config, logger" do
			subject.should_not be_nil
		end
	end 

	describe "#execute" do 
		it 'should start ec2 instance and start worker daemon on it ' do
			@config.should_receive('ami_id'){'ami-7542c01c'}
			@config.should_receive('key_pair'){'identity.pub'}
			@config.should_receive('region'){'us-east-1a'}


			instance = double('instance')
			instance.should_receive('start').with('i1234')
			instances.should_receive('ip_address'){'192.168.0.3'}
			instances = double('instances')
			instances.should_receive('create').with({:image_id => "ami-7542c01c",:availability_zone => 'us-east-1a', :security_groups => 'admin' }).and_return('i-1234')
			instances.should_receive(':[]').with('i-1234').and_return(instace)

			@ec2.should_receive('instances') {instances}

			#@ssh.should_receive.command()


			subject.execute
		end
	end 
end 