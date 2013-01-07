require 'spec_helper'

describe InfrastructureProvisioner do
	before(:each) do     
		@swf = double('swf')
		@config = double('config')
		@tasks_factory = double('tasks')
	end


	subject { InfrastructureProvisioner.new  :params => @params, :options => @options, 
		:logger => $stderr, :config=>@config, :swf => @swf, :tasks => @tasks_factory }

	describe ".new" do
		it "should accept params, options, config, logger" do 
			subject.should_not be_nil
		end
	end


	describe '#execute' do 
		it 'should create and execute provision tasks' do 

			@config.should_receive(:[]).with(:domain) {'test1'}
			@config.should_receive(:[]).with(:provision_task_list) {'provision-tasks'}

			task = double('task')
			task.should_receive('execute')
			@tasks_factory.should_receive('from_provision_event'){task}

			at = double('activity_tasks') 
			domain = double('domain')
			domain.should_receive('activity_tasks') {at}


			domains = double('domains')
			domains.should_receive(:[]){ domain }
			
			@swf.should_receive('domains'){ domains }

			activity_event = double('activity_event')

			at.should_receive('poll') do |&arg|
				arg.call activity_event
			end  

			subject.execute
		end 
	end 
end 

