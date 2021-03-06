require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'alsa_backup/cli'

describe AlsaBackup::CLI, "execute" do
  before(:each) do
    @stdout_io = StringIO.new
    @file = test_file

    @recorder = AlsaBackup::Recorder.new(@file)
    @recorder.stub!(:start)
    AlsaBackup.stub!(:recorder).and_return(@recorder)
  end

  def execute_cli(options = {})
    options = { :file => @file, :length => 2 }.update(options)
    arguments = options.collect do |key,value| 
      if value
        "--#{key}".tap do |argument|
          argument << "=#{value}" unless value == true
        end
      end
    end.compact
    
    AlsaBackup::CLI.execute(@stdout_io, *arguments)
    @stdout_io.rewind
    @stdout = @stdout_io.read
  end
  
  it "should use AlsaBackup.recorder" do
    AlsaBackup.should_receive(:recorder).and_return(@recorder)
    execute_cli
  end

  it "should set the record file with specified one" do
    @recorder.should_receive(:file=).with(file = "dummy")
    execute_cli :file => file
  end

  it "should start the AlsaBackup.recorder" do
    @recorder.should_receive(:start)
    execute_cli
  end

  it "should start the recorder with specified length" do
    @recorder.should_receive(:start).with(length = 60)
    execute_cli :length => length
  end

  it "should start the record without length if not specified" do
    @recorder.should_receive(:start).with(nil)
    execute_cli :length => nil
  end

  it "should execute specified config file" do
    execute_cli :config => fixture_file('config_test.rb'), :file => nil
    AlsaBackup.recorder.file.should == "config_test_ok"
  end

  it "should override config file values with command line arguments" do
    argument_file = "dummy"
    execute_cli :config => fixture_file('config_test.rb'), :file => argument_file
    AlsaBackup.recorder.file.should == argument_file
  end

  it "should write pid in specified file" do
    pid_file = test_file("pid")
    execute_cli :pid => pid_file

    IO.read(pid_file).strip.should == $$.to_s
  end

  it "should daemonize the process with option background" do
    Daemonize.should_receive(:daemonize)
    execute_cli :background => true
  end

end
