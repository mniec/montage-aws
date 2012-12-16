require 'spec_helper'

class Sth
  def initialize params, options
  end
end

class Sth1
  def initialize params, options
  end
end

describe Tasks do

  describe ".validate" do
    it "should return true to valid spec" do
      r = Tasks.validate({:valid =>Sth, :valid1=>Sth})
      r.should be_true
    end

    it "should return false to invalid spec" do
      [{:ala=>"ASD"},{"asdf"=>Sth1},{"asdf"=>1}].each do |e|
        r = Tasks.validate({"invalid"=>Sth1})
        r.should be_false
      end
    end
  end

  describe ".new" do
    it "should get definitions of available tasks" do
      available_tasks = {:sth=>Sth,:sth1=>Sth1}
      tasks = Tasks.new available_tasks
      tasks.should_not be_nil
      tasks.available_tasks.should_not be_nil
    end

    it "should throw error if task name is not a symbol" do
      lambda { Tasks.new({"dupa"=> Sth }) }.should raise_error(ArgumentError)
    end

    it "should throw error if task class is not valid" do
      lambda { Tasks.new({:dupa => "Sth1" }) }.should raise_error(ArgumentError)
    end
  end

  describe "#create_from_cmd" do
    before(:each) do 
      @task = Tasks.new({:sth => Sth, :sth1 => Sth1})
    end

    it "should check if generates valid task instance from cmd" do
      cmd = double("cmd")
      cmd.should_receive(:task) { :sth }
      cmd.should_receive(:params) { ["hello", "hello"] }
      cmd.should_receive(:options) { { :p => "1" } }

      sth = @task.create_from_cmd cmd
    end
    
    it "should raise error if there is no such task available" do
      cmd = double("cmd")
      cmd.should_receive(:task) { :sth2 }
      lambda { @task.create_from_cmd(cmd) }.should raise_error(RuntimeError, "No such task available")
    end
    
  end
end
