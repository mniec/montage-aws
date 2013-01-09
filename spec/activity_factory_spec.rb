require "spec_helper"

describe ActivityFactory do

  before(:each) do
    @config = double('config')
    @swf = double('swf')
    @ec2 = double('ec2')
    @montage = double('montage')
    @args = {:config => @config, :swf => @swf, :ec2 => @ec2, :montage => @montage}
    @activity_factory = double('activity_factory')
  end

  describe "#from_worker_task" do
    subject do
      ActivityFactory.new({:project => MockActivity}, @args)
    end
    it "should generate valid project task from passed activity obj" do
      activity_type = double('activity_type')
      activity_type.should_receive(:name){"project"}

      activity_task = double('activity_task')
      activity_task.should_receive(:activity_type){activity_type}

      subject.from_worker_task activity_task
    end

  end
end