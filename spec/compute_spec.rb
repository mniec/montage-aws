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
    @config.stub :[]
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
        c = Compute.new :params => ["2","1","1","1","1"]
        lambda { c.execute }.should raise_error
        c = Compute.new :params => ["asdf","1"]
        lambda { c.execute }.should raise_error
        c = Compute.new :params => ["asdf","1.0"]
        lambda { c.execute }.should raise_error
      end
    end

    describe "if valid cords are given" do
      subject { Compute.new :params => ["53.3","33.3","1", "1"], :options=> {}, :swf=>@swf, :config=>@config }
      it "should start workflow" do
        @config.should_receive(:[]).with(:workflow_name)
        @config.should_receive(:[]).with(:workflow_version)
        @config.should_receive(:[]).with(:domain)
        @workflow_type.should_receive(:start_execution).with({:input => "53.3 33.3 1 1 2"})

        subject.execute
      end

      describe "should make use of the '--machines' option" do

        it "should check if machines param can be parsed as integer" do
          c = Compute.new :params => ["53.3","33.3","1", "1"],
          :options => {:machines => "10z"}, :swf=>@swf, :config=> @config
          lambda { c.compute }.should raise_error
          
        end
        it "should pass machines number as a 3rd argument to workflow input" do
          @workflow_type.should_receive(:start_execution).with(:input => "53.3 33.3 1 1 10")
          c = Compute.new :params => ["53.3", "33.3", "1", "1"],
          :options => {:machines => "10"}, :swf=>@swf, :config=> @config
          c.execute
        end


      end
    end

  end

end
