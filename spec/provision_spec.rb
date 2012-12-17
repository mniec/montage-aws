require 'spec_helper'

describe Provision do
  before(:each) do 
    
    @aws = double('aws')
    @config = double('config')

  end
  describe ".new" do
    
    it "should accept params, options, config, logger" do 
      @params = []
      @options = {}
      p1 = Provision.new  :params => @params, :options => @options, 
      :logger => $stderr, :config=>@config, :aws => @aws 
      
      p1.should_not be_nil
    end
    
  end

  describe "#execute" do 
    it "should create a new domain with new activites types" do
      p1 = Provision.new :params => [], :options => {}, 
      :config => @config, :logger => $stderr, :aws => @aws
      
      @config.should_receive(:domain){'test1'}
      @config.should_receive(:default_task_list){'main'}
      @config.should_receive(:workflow_name){'test_wf'}
      @config.should_receive(:workflow_version){'1'}.at_least(:once)
      
      workflow_types = double('workflow_types')
      workflow_types.should_receive(:create)

      activity_types = double('activity_types')
      activity_types.should_receive(:create).exactly(2)

      domain = double('domain')
      domain.should_receive(:workflow_types){ workflow_types }
      domain.should_receive(:activity_types){ activity_types }.at_least(:once)
      
      domains = double('domains')
      domains.should_receive(:create){ domain }

      swf = double('swf')
      swf.should_receive(:domains){ domains }

      @aws.should_receive(:new){ swf }
      p1.execute
    end
  end
  
end