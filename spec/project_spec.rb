require 'spec_helper'

describe ProjectAndDownload do
  before(:each) do
    @task = double('activity_task')
    @swf = double('swf')
    @s3 = double('s3')
    @config = double('config')
    @montage_helper = double('montage_helper')
  end

  describe "#execute" do
    subject { ProjectAndDownload.new(@task, :swf => @swf, :s3=> @s3, :config => @config, :montage_helper=>@montage_helper) }
    it 'should call montage helper to download all the files' do
      run_id = "23sdfasdfasdf2bpi232i3on"
      file1 = "sth.tar.gz"
      file2 = "sth1.tar.gz"
      line1 = "http://sth #{file1}"
      line2 = "http://sth1 #{file2}"
      list = "/tmp/#{run_id}/raw.tbl"
      dir = "/tmp/#{run_id}/raw"
      out_dir = "/tmp/#{run_id}/projected"

      @task.should_receive(:record_heartbeat!).with(:details => "0%")
      @task.should_receive(:record_heartbeat!).with(:details => "33%")
      @task.should_receive(:record_heartbeat!).with(:details => "66%")
      @task.should_receive(:record_heartbeat!).with(:details => "100%")
      @task.should_receive(:activity_id){"kpwoeeirubtreibg"}
      @task.should_receive(:workflow_execution){ double(:run_id => run_id, :input => "1 2.0 3.0 4.0 10") }.any_number_of_times
      @task.should_receive(:input) { "#{line1}\n#{line2}\n" }
      @task.should_receive(:complete!)

      @montage_helper.should_receive(:get).with(instance_of(String), [line1, line2])
      @montage_helper.should_receive(:make_list).with(kind_of(String), kind_of(String))
      @montage_helper.should_receive(:make_template).with(kind_of(String), 1.0, 2.0, 3.0, 4.0)
      @montage_helper.should_receive(:project).with(kind_of(String),kind_of(String), kind_of(String), kind_of(String), kind_of(String)) 

      bucket = double('bucket')      
      buckets = double('buckets')
      object = double('s3object')

      subject.execute
    end

  end

end
