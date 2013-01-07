require 'spec_helper'

describe Decider do
  before(:each) do
    @swf = double('swf')
    @config = double('config')
    @config.stub(:[]) { "conf" }
    @tasks = double('tasks')
  end

  subject { Decider.new :params=> [], :options => {},
    :config => @config, :logger => $stderr, :swf => @swf, :tasks=>@tasks}

  describe ".new" do
    it "should accept params, options, config, logger" do
      subject.should_not be_nil
    end
  end

  describe "#execute" do

    it "should poll for tasks" do
      @config.should_receive(:[]).with(:domain) {'test1'}
      @config.should_receive(:[]).with(:default_task_list) {'task_list'}

      decision_tasks = double('decision_tasks')
      decision_tasks.should_receive(:poll).and_yield(nil)

      domain = double('domain')
      domain.should_receive(:decision_tasks){ decision_tasks }

      domains = double('domains')
      domains.should_receive(:[]){ domain }

      @swf.should_receive(:domains){ domains }
      subject.should_receive :handle_task
      subject.execute
    end
  end

  describe "#handle_task" do
    before(:each) do
      @task = double('task')
      @task.should_receive :complete!
      @event = double('event')
    end
    it "should get new events" do

      @task.should_receive(:new_events){ [] }
      subject.handle_task @task
    end

    it "should check event type" do
      @event.should_receive(:event_type)
      @task.should_receive(:new_events) { [@event] }
      subject.handle_task @task
    end

    it "should shecule EC2 provisioning and fetching raw data when workflow started" do
      @event.stub(:event_type).and_return("WorkflowExecutionStarted")
      @task.should_receive(:new_events) { [@event] }
      subject.should_receive(:handle_workflow_start)
      subject.handle_task @task
    end

  end

  describe "#handle_workflow_start" do
    before(:each) do
      @task = double('task')
      @event = double('event')
    end

    it "should schedule provision EC2" do
      @event.stub(:event_type).and_return("WorkflowExecutionStarted")
      attrs = double('attributes')
      attrs.should_receive(:[]) { "1 1 10" }
      @event.stub(:attributes) { attrs }

      @task.should_receive(:schedule_activity_task).with({:name=> "provision", :version => "conf"}).exactly(10)

      subject.handle_workflow_start @event, @task
    end
  end
end
