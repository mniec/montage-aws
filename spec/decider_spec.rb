require 'spec_helper'

describe Decider do
  before(:each) do 
    @swf = double('swf')
    @config = double('config')
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
    it "should pool for tasks" do
      @config.should_receive(:[]).with(:domain) {'test1'}
      @config.should_receive(:[]).with(:default_task_list) {'task_list'}
      
      decision_tasks = double('decision_tasks')
      decision_tasks.should_receive(:poll).and_yield(nil)
      
      domain = double('domain')
      domain.should_receive(:decision_tasks){ decision_tasks }
            
      domains = double('domains')
      domains.should_receive(:[]){ domain }
      
      @swf.should_receive(:domains){ domains }
      subject.should_receive :execute_task
      subject.execute
    end
  end

  describe "#execute_task" do 
    it "should get new events" do 
      task = double('task')
      task.should_receive(:new_events){ [] }
      subject.execute_task task
    end

    it "should pass event to factory in order to get task to execute" do 
      event = double('event')
      task=double('task')
      task.should_receive(:new_events) { [event] }

      decTask = double('decTask')
      decTask.should_receive(:execute)
      @tasks.should_receive(:from_decision_event) { decTask }
      subject.execute_task task
    end
  end
  
  
end

