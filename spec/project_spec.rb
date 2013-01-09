require 'spec_helper'

describe Project do
  before(:each) do
    @task = double('activity_task')
    @swf = double('swf')
    @s3 = double('s3')
    @config = double('config')
    @montage = double('montage')

  end

  describe "#execute" do
    subject { Project.new(:activity_task=>@task, :swf => @swf, :s3=> @s3, :config => @config, :montage=>@montage, :logger=>double(:puts=>true)) }
    it 'should call montage helper to download all the files' do
      run_id = "23sdfasdfasdf2bpi232i3on"
      file1 = "sth.tar.gz"
      file2 = "sth1.tar.gz"
      line1 = "http://sth #{file1}"
      line2 = "http://sth1 #{file2}"
      list = "/tmp/#{run_id}/raw.tbl"
      dir = "/tmp/#{run_id}/raw"
      out_dir = "/tmp/#{run_id}/projected"

      @config.should_receive(:[]).with(:s3_bucket){'bucket'}

      @task.should_receive(:record_heartbeat!).with(:details => "0%")
      @task.should_receive(:record_heartbeat!).with(:details => "33%")
      @task.should_receive(:record_heartbeat!).with(:details => "66%")
      @task.should_receive(:record_heartbeat!).with(:details => "100%")
      @task.should_receive(:activity_id){"kpwoeeirubtreibg"}
      @task.should_receive(:workflow_execution){ double(:run_id => run_id, :input => "1.0 2.0 3.0 4.0 10") }.any_number_of_times
      @task.should_receive(:input) { "1.0 2.0 3.0 4.0\n#{line1}\n#{line2}\n" }
      @task.should_receive(:complete!).with(:result=>nil)

      @montage.should_receive(:get).with(instance_of(String), [line1, line2])
      @montage.should_receive(:make_list).with(kind_of(String), kind_of(String))
      @montage.should_receive(:make_template).with(kind_of(String), 1.0, 2.0, 3.0, 4.0)
      @montage.should_receive(:project).with(kind_of(String),kind_of(String), kind_of(String), kind_of(String), kind_of(String))

      bucket = double('bucket')
      buckets = double('buckets')
      object = double('s3object')

      subject.execute
    end

  end

end
