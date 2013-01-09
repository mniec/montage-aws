require "spec_helper"

describe CmdFactory do

  before(:each) do
    @config = double('config')
    @swf = double('swf')
    @ec2 = double('ec2')
    @montage = double('montage')
    @args = {:config => @config, :swf => @swf, :ec2 => @ec2, :montage => @montage}
    @activity_factory = double('activity_factory')
  end

  describe "#create_from_cmd" do
    subject{ CmdFactory.new(@activity_factory, {:sth => Sth, :sth1 => Sth1}, @args) }

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

end