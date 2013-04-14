require File.dirname(__FILE__) + '/../spec_helper.rb'

require 'alsa_backup/recorder'

describe AlsaBackup::Recorder do

  let(:file) { test_file }
  subject { AlsaBackup::Recorder.new(file) }

  def self.alsa_device_available?
    File.exists? "/proc/asound/card0/id"
  end

  if alsa_device_available?
    it "should not raise an error on start" do
      subject.start(2)
      lambda { subject.start(2) }.should_not raise_error
    end
  end

  it "should use the specified alsa device" do
    subject.device = alsa_device = "dummy"
    ALSA::PCM::Capture.should_receive(:open).with(alsa_device, anything)
    subject.open_capture
  end

  it "should use the specified sample rate" do
    subject.sample_rate = 48000
    subject.format[:sample_rate].should == subject.sample_rate
  end

  it "should use the specified channels" do
    subject.channels = 4
    subject.format[:channels].should == subject.channels
  end

  it "should use 44100 as default sample rate" do
    subject.sample_rate.should == 44100
  end

  it "should use 2 as default channels" do
    subject.channels.should == 2
  end

  it "should use hw:0 as default device" do
    subject.device.should == "hw:0"
  end

  it "should stop the recording on Interrupt error" do
    subject.stub!(:open_writer).and_raise(Interrupt)
    subject.start
  end

  describe "alsa_options" do
    
    it "should use buffer_time if specified" do
      subject.buffer_time = 100000
      subject.alsa_options[:buffer_time].should == 100000
    end

    it "should use period_time if specified" do
      subject.period_time = 100000
      subject.alsa_options[:period_time].should == 100000
    end

  end

  describe "error handler" do

    class TestErrorHandler

      def initialize(proc)
        proc = Proc.new { |e| proc } unless Proc == proc
        @proc = proc
      end

      def call(e)
        if @proc
          response = @proc.call(e)
          @proc = nil
          response
        end
      end

    end
    
    before(:each) do
      AlsaBackup::Writer.stub!(:open).and_raise("dummy")
      subject.stub!(:sleep)
    end

    it "should raise error when error handler is nil" do
      subject.error_handler = nil
      lambda { subject.start }.should raise_error
    end

    it "should raise error when error handler returns nil or false" do
      subject.error_handler = TestErrorHandler.new(nil)
      lambda { subject.start }.should raise_error
    end

    def start_recorder(limit = nil)
      subject.start(limit)
    rescue RuntimeError

    end

    it "should retry when error handler returns something (not false or nil)" do
      subject.error_handler = TestErrorHandler.new(true)
      AlsaBackup::Writer.should_receive(:open).twice().and_raise("dummy")

      start_recorder
    end

    it "should use the error handler response as sleep time if numerical" do
      subject.error_handler = TestErrorHandler.new(error_handler_response = 5)
      subject.should_receive(:sleep).with(error_handler_response)
      start_recorder
    end

    it "should sleep 5 seconds when the error handler response is a number" do
      subject.error_handler = TestErrorHandler.new(true)
      subject.should_receive(:sleep).with(5)
      start_recorder
    end

    it "should not use error handler when recorder is started with a time length" do
      subject.error_handler = mock("error_handler")
      subject.error_handler.should_not_receive(:call)

      start_recorder(2)
    end

  end

  describe "open_writer" do
    
    it "should use the given on_close block" do
      on_close_block = Proc.new {}
      subject.on_close &on_close_block

      AlsaBackup::Writer.should_receive(:open).with(hash_including(:on_close => on_close_block))
      subject.open_writer {}
    end

    it "should use the directory" do
      AlsaBackup::Writer.should_receive(:open).with(hash_including(:directory => subject.directory))
      subject.open_writer {}
    end

    it "should use the file" do
      AlsaBackup::Writer.should_receive(:open).with(hash_including(:file => subject.file))
      subject.open_writer {}
    end

    it "should use the format wav pcm_16 with wanted sample_rate and channels" do
      AlsaBackup::Writer.should_receive(:open).with(hash_including(:format => subject.format(:format => "wav pcm_16")))
      subject.open_writer {}
    end

  end

  describe "open_capture" do

    it "should use specified device" do
      subject.stub :device => "dummy"
      ALSA::PCM::Capture.should_receive(:open).with("dummy", anything())
      subject.open_capture {}
    end
    
    it "should use alsa_options" do
      subject.stub :alsa_options => { :dummy => true }
      ALSA::PCM::Capture.should_receive(:open).with(anything(), subject.alsa_options)
      subject.open_capture {}
    end

  end

end
