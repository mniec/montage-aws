require "spec_helper"

describe TaskFactory do

  before(:each) do
    @config = double('config')
    @swf = double('swf')
    @ec2 = double('ec2')
    @montage = double('montage')
    @args = {:config => @config, :swf => @swf, :ec2 => @ec2, :montage => @montage}
  end

  describe ".validate" do
    it "should return true to valid spec" do
      r = TaskFactory.validate({:valid =>Sth, :valid1=>Sth1})
      r.should be_true
    end

    it "should return false to invalid spec" do
      [{:ala=>"ASD"},{"asdf"=>Sth1},{"asdf"=>1}].each do |e|
        r = TaskFactory.validate(e)
        r.should be_false
      end
    end
  end

  describe ".new" do
    it "should get definitions of available tasks, config swf and ec2" do
      available_tasks = {:sth=>Sth,:sth1=>Sth1}
      tasks = TaskFactory.new(available_tasks, @args)
      tasks.should_not be_nil
      tasks.available_tasks.should_not be_nil
    end

    it "should throw error if task name is not a symbol" do
      lambda { TaskFactory.new({"dupa"=> Sth }, :config => @config, :swf=>@swf, :ec2 => @ec2) }.should raise_error(ArgumentError)
    end

    it "should throw error if task class is not valid" do
      lambda { TaskFactory.new({:dupa => "Sth1" }, :config => @config, :swf=>@swf, :ec2=> @ec2) }.should raise_error(ArgumentError)
    end
  end

end