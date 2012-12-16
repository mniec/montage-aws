require 'spec_helper'


describe Cmd do
  describe "#new" do
    before(:each) do
      @args = %w{ala -t sth sth --color asdf -c -l 3 -p}
    end

    it "shoud get params from array and return task to execute" do
      cmd = Cmd.new @args
      cmd.should_not be_nil
    end

    it "should set proper task name" do
      cmd = Cmd.new @args
      cmd.task.should be :ala
    end

    it "should return nil if no args specified" do
      cmd = Cmd.new []
      cmd.task.should be nil
    end


    it "should set options to empty hash if no args passed " do
      cmd = Cmd.new ["ala"]
      cmd2 = Cmd.new []
      cmd.options.should be {}
      cmd2.options.should be {}
    end

    it "should set options properly if they are passed" do
      opts = {
        :t => ['sth', 'sth'],
        :color => "asdf",
        :c => true,
        :l => '3',
        :p => true}

      cmd = Cmd.new @args
      cmd.options.should eq opts
    end

    it "should initialize task params" do 
      cmd = Cmd.new [@args.shift].concat(%w{ok hello}).concat(@args)
      cmd.params.should eq ["ok", "hello"]
    end

  end

end
