require 'spec_helper'

describe Worker do
  before(:each) do
    @swf = double('swf')
    @config = double('config')
    @config.stub(:[]) { "conf" }
    @tasks = double('tasks')
    @logger = double(:puts=>true)
    @montage = double(:divide=>[])
  end

  subject { Worker.new :params=> [], :options => {},
    :config => @config, :logger => @logger, :swf => @swf, 
    :task_factory=>@tasks, :montage=> @montage}

  describe ".new" do
    it "should accept params, options, config, logger" do
      subject.should_not be_nil
    end
  end

  describe "#execute" do
    it "should poll for activity tasks" do
      @config.should_receive(:[]).with(:domain) {'test1'}
      @config.should_receive(:[]).with(:compute_task_list) {'task_list'}

      activity_tasks = double('activity_tasks')
      activity_tasks.should_receive(:poll).and_yield(nil)

      domain = double('domain')
      domain.should_receive(:activity_tasks){ activity_tasks }

      domains = double('domains')
      domains.should_receive(:[]){ domain }

      @swf.should_receive(:domains){ domains }
      task = double('task')
      task.should_receive(:execute)
      @tasks.should_receive(:from_worker_task){task}
      subject.execute
    end
  end



end
