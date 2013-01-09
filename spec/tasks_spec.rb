require 'spec_helper'

class Sth
  def initialize params
  end
end

class Sth1
  def initialize params
  end
end

describe Tasks do
  before(:each) do
    @config = double('config')
    @swf = double('swf')
    @ec2 = double('ec2')
    @montage = double('montage')
    
    @args = {:config => @config, :swf => @swf, :ec2 => @ec2, :montage => @montage}
  end
  describe ".validate" do
    it "should return true to valid spec" do
      r = Tasks.validate({:valid =>Sth, :valid1=>Sth1})
      r.should be_true
    end

    it "should return false to invalid spec" do
      [{:ala=>"ASD"},{"asdf"=>Sth1},{"asdf"=>1}].each do |e|
        r = Tasks.validate(e)
        r.should be_false
      end
    end
  end

  describe ".new" do
    it "should get definitions of available tasks, config swf and ec2" do
      available_tasks = {:sth=>Sth,:sth1=>Sth1}
      tasks = Tasks.new(available_tasks, @args)
      tasks.should_not be_nil
      tasks.available_tasks.should_not be_nil
    end

    it "should throw error if task name is not a symbol" do
      lambda { Tasks.new({"dupa"=> Sth }, :config => @config, :swf=>@swf, :ec2 => @ec2) }.should raise_error(ArgumentError)
    end

    it "should throw error if task class is not valid" do
      lambda { Tasks.new({:dupa => "Sth1" }, :config => @config, :swf=>@swf, :ec2=> @ec2) }.should raise_error(ArgumentError)
    end
  end

  describe "#create_from_cmd" do
    subject{ Tasks.new({:sth => Sth, :sth1 => Sth1}, @args) }

    it "should check if generates valid task instance from cmd" do
      cmd = double("cmd")
      cmd.should_receive(:task) { :sth }
      cmd.should_receive(:params) { ["hello", "hello"] }
      cmd.should_receive(:options) { { :p => "1" } }

      sth = subject.create_from_cmd cmd
      sth.should_not be_nil
    end
    
    it "should raise error if there is no such task available" do
      cmd = double("cmd")
      cmd.should_receive(:task) { :sth2 }
      lambda { subject.create_from_cmd(cmd) }.should raise_error(RuntimeError, "No such task available")
    end    
  end
  
  describe "#from_decision_event" do
    subject{ Tasks.new({:sth => Sth, :sth1 => Sth1}, @args) }

    it "should check for event type" do
      event = double("event")
      event.should_receive(:event_type){"sth1"}
      task = subject.from_decision_event event
    end
    it 'should fail if there is no class associated with particular event' do
      event =double("event")
      event.should_receive(:event_type){"NotExisting"}
      lambda { subject.from_decision_event event}.should raise_error(RuntimeError, "No such task available")
    end
    it "should create a valid task" do 
      event = double("event")
      event.stub(:event_type).and_return("sth")
      task = subject.from_decision_event event
      task.should_not be_nil
      task.should be_an_instance_of Sth
    end
  end
  
  describe "#from_worker_task" do 
    subject do
      Tasks.new({:project => Sth1}, @args)
    end
    it "should generate valid project task from passed activity obj" do 
      activity_type = double('activity_type')
      activity_type.should_receive(:name){"project"}

      activity_task = double('activity_task')
      activity_task.should_receive(:activity_type){activity_type}

      task = subject.from_worker_task activity_task
    end
    
  end
end
