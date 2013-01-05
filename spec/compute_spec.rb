require 'spec_helper'

describe Compute do

  before(:each) do
    @workflow_type = double()
    @workflow_type.stub(:start_execution)
    @workflow_types = double()
    @workflow_types.stub(:[]) { @workflow_type }

    @domain = double()
    @domain.stub(:workflow_types) { @workflow_types }

    @domains = double()
    @domains.stub(:[]) { @domain }

    @swf = double('swf')
    @swf.stub(:domains){ @domains }

    @config = double('config')
  end

  describe ".new" do
    it "should accept params, options, config, logger" do
      @params = []
      @options = {}
      p1 = Compute.new  :params => @params, :options => @options,
      :logger => $stderr, :config=>@config, :swf => @swf

      p1.should_not be_nil
    end
  end

  describe "#execute" do

    describe "should handle bad input" do
      it "should fail if cords are not numbers" do
        c = Compute.new :params => ["a","a"]
        lambda { c.execute }.should raise_error
        c = Compute.new :params => ["2","1","1"]
        lambda { c.execute }.should raise_error
        c = Compute.new :params => ["asdf","1"]
        lambda { c.execute }.should raise_error
        c = Compute.new :params => ["asdf","1.0"]
        lambda { c.execute }.should raise_error
      end
    end

    describe "if valid cords are given" do
      subject { Compute.new :params => ["1", "1"], :swf=>@swf, :config=>@config }
      it "should start workflow" do
        @config.should_receive(:[]).with(:workflow_name)
        @config.should_receive(:[]).with(:workflow_version)
        @config.should_receive(:[]).with(:domain)
        @workflow_type.should_receive(:start_execution).with({:input => "1 1"})

        subject.execute
      end
    end

  end

end
