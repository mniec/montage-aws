require 'spec_helper'

describe Provision do
  before(:each) do 
    
    @swf = double('swf')
    @config = double('config')
    @s3 = double('s3')

  end
  describe ".new" do
    
    it "should accept params, options, config, logger" do 
      @params = []
      @options = {}
      p1 = Provision.new  :params => @params, :options => @options, 
      :logger => $stderr, :config=>@config, :swf => @swf
      
      p1.should_not be_nil
    end
    
  end

  describe "#execute" do 
    it "should create a new domain with new activites types" do
      p1 = Provision.new :params => [], :options => {}, 
      :config => @config, :logger => $stderr, :swf => @swf, :s3 => @s3
      
      @config.should_receive(:[]).with(:domain) { 'test1' }
      @config.should_receive(:[]).with(:default_task_list){ 'main' }
      @config.should_receive(:[]).with(:workflow_name){ 'test_wf' }
      @config.should_receive(:[]).with(:workflow_version) { '1' }.at_least(:once)
      @config.should_receive(:[]).with(:provision_task_list) { "task_list" }
      @config.should_receive(:[]).with(:compute_task_list) { "task_list" }
      @config.should_receive(:[]).with(:s3_bucket) { "mybucket"  }
      
      workflow_types = double('workflow_types')
      workflow_types.should_receive(:create)

      activity_types = double('activity_types')
      activity_types.should_receive(:create).exactly(3)

      domain = double('domain')
      domain.should_receive(:workflow_types){ workflow_types }
      domain.should_receive(:activity_types){ activity_types }.at_least(:once)
      
      domains = double('domains')
      domains.should_receive(:create){ domain }

      @swf.should_receive(:domains){ domains }

      bucket = double('bucket')
      bucket.should_receive(:exists?){false}
      
      buckets = double('buckets')
      buckets.should_receive(:[]).with('mybucket') { bucket }
      buckets.should_receive(:create).with('mybucket')
      
      @s3.should_receive(:buckets){ buckets }
      @s3.should_receive(:buckets){ buckets }

      p1.execute
    end
  end
  
end
