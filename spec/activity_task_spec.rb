require "spec_helper"

describe ActivityTask do

  before(:each) do
    @task    = double('activity_task')
    @config  = double('config')
    @logger  = double('logger', :puts => true)
    @swf     = double('swf')
    @s3      = double('s3')
    @mh      = double('montage')
  end

  subject do
    ActivityTask.new @task,
                     :config         => @config,
                     :logger         => @logger,
                     :tasks          => @tasks,
                     :s3             => @s3,
                     :montage        => @mh

  end

  it "should initialize right params" do
    subject.activity_task.should be @task
    subject.config.should be @config
    subject.logger.should be @logger
    subject.s3.should be @s3
    subject.montage.should be @mh
  end
end