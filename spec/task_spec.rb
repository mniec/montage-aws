require "spec_helper"

describe Task do

  before(:each) do
    @config  = double('config')
    @logger  = double('logger', :puts => true)
    @swf     = double('swf')
    @s3      = double('s3')
    @mh      = double('montage')
  end

  subject do
    Task.new         :config         => @config,
                     :logger         => @logger,
                     :tasks          => @tasks,
                     :s3             => @s3,
                     :montage        => @mh

  end
  it "should initialize task with correct params" do
    subject.config.should be @config
    subject.logger.should be @logger
    subject.s3.should be @s3
    subject.montage.should be @mh
  end
end