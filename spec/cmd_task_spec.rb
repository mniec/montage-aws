require "spec_helper"

describe CmdTask do
  before(:each) do
    @config  = double('config')
    @logger  = double('logger', :puts => true)
    @tasks   = double('tasks')
    @swf     = double('swf')
    @s3      = double('s3')
    @mh      = double('montage')
  end

  subject do
    CmdTask.new     :params         => %w{a b},
                    :options        => {:p => true},
                    :config         => @config,
                    :logger         => @logger,
                    :task_factory   => @tasks,
                    :s3             => @s3,
                    :montage => @mh

  end

  it "it should initialize variables properly" do
    subject.params.should       eq %w{a b}
    subject.options.should      eq({:p => true})
    subject.config.should       be @config
    subject.logger.should       be @logger
    subject.task_factory.should be @tasks
    subject.s3.should           be @s3
    subject.montage.should      be @mh
  end

  it "should use stderr if no logger is passed" do
    t = CmdTask.new :params => %{a, d}
    $stderr.should_receive(:puts)
    t.info "ala"
  end

  describe "#info" do
    it "should call logger#puts" do
      @logger.should_receive(:puts)
      subject.info "ala"
    end
  end
end