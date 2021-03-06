require File.dirname(__FILE__) + '/../spec_helper.rb'

describe AlsaBackup::Writer do

  let(:file) { "test.wav" }
  let(:directory) { test_directory }

  subject { AlsaBackup::Writer.new :directory => directory, :file => file }

  context "when created" do

    it "should use the :directory option as directory" do
      AlsaBackup::Writer.new(:directory => directory).directory.should == directory
    end

    it "should use the :file option as file" do
      AlsaBackup::Writer.new(:file => file).file.should == file
    end

    it "should use the :format option as format" do
      format = {:format => "test"}
      AlsaBackup::Writer.new(:format => format).format.should == format
    end

    it "should use default_format when no specified" do
      AlsaBackup::Writer.new.format.should == AlsaBackup::Writer.default_format
    end

    it "should include the given :on_close proc in on_close_callbacks" do
      on_close_proc = Proc.new {}
      AlsaBackup::Writer.new(:on_close => on_close_proc).on_close_callbacks.should include(on_close_proc)
    end
    
  end

  describe "#on_close" do

    class TestCallback

      attr_reader :file

      def call(file)
        @file = file
      end

      def invoked?
        not @file.nil?
      end

    end

    let(:callback) { TestCallback.new }

    before(:each) do
      subject.on_close_callbacks << callback
    end
    
    it "should check if file is empty" do
      AlsaBackup::Writer.should_receive(:delete_empty_file).with(file).and_return(true)
      subject.on_close(file)
    end

    context "when file was empty" do

      before(:each) do
        AlsaBackup::Writer.stub :delete_empty_file => true
      end

      it "should not invoke callbacks" do
        subject.on_close(file)
        callback.should_not be_invoked
      end

    end

    it "should invoke all on_close_callbacks" do
      subject.on_close(file)
      callback.should be_invoked
    end

    it "should ignore exception from callbacks" do
      callback.stub!(:call).and_raise("Error")
      lambda { subject.on_close(file) }.should_not raise_error
    end

  end

  describe ".delete_empty_file" do

    let(:file) { "tmp/deleted_empty_file" }

    after(:each) do
      File.delete(file) if File.exists?(file)      
    end

    context "when file contains 44 bytes or less" do

      before(:each) do
        File.open(file, "w") { |f| f.write 'a'*44 }
      end

      it "should remove a file" do
        AlsaBackup::Writer.delete_empty_file(file)
        File.exists?(file).should be_false
      end

      it "should return true" do
        AlsaBackup::Writer.delete_empty_file(file).should be_true
      end

    end

    context "when file contains more than 44 bytes" do

      before(:each) do
        File.open(file, "w") { |f| f.write "a"*45 }
      end

      it "should not remove the file" do
        AlsaBackup::Writer.delete_empty_file(file)
        File.exists?(file).should be_true
      end

      it "should return false" do
        AlsaBackup::Writer.delete_empty_file(file).should be_false
      end
                                                      
    end


  end

  describe "file" do
    
    it "should accept file as string" do
      subject.file = file_name = "dummy"
      subject.file.should == file_name
    end

    it "should accept file as Proc" do
      file_name = "dummy"
      subject.file = Proc.new { file_name }
      subject.file.should == file_name
    end
    
    context "when the file is a Proc" do

      it "should pass true as argument when the Writer retrieves a first filename, false otherwise" do
        subject.file = Proc.new { |first| "dummy-#{first}" }
        subject.file.should eq("dummy-true")
        subject.stub :first_file? => false
        subject.file.should eq("dummy-false")
      end

    end

  end

  describe "first_file? " do
    
    it "should be true before the first close_file" do
      subject.should be_first_file
    end

    it "should be false after close_file" do
      subject.sndfile
      subject.close_file
      subject.should_not be_first_file
    end

  end

  describe "rename_existing_file" do

    it "should keep file if not exists" do
      File.should_receive(:exists?).with(file).and_return(false)
      File.should_not_receive(:rename)
      AlsaBackup::Writer.rename_existing_file(file)
    end

    it "should try to suffix with '-n' to find a free name" do
      File.stub!(:exists?).and_return(true)

      free_file = File.suffix_basename(file, "-99")
      File.should_receive(:exists?).with(free_file).and_return(false)

      File.should_receive(:rename).with(file, free_file)
      AlsaBackup::Writer.rename_existing_file(file)
    end

    it "should raise an error when no free file is found" do
      File.stub!(:exists?).and_return(true)
      lambda do
        AlsaBackup::Writer.rename_existing_file(file)
      end.should raise_error
    end

  end

  describe "close" do

    it "should close file (via close_file method)" do
      subject.should_receive(:close_file)
      subject.close
    end
    
  end

  describe "close_file" do
    
    it "should close current sndfile" do
      sndfile = subject.sndfile
      sndfile.should_receive(:close)
      subject.close_file
    end

    it "should notify on_close callbacks (via on_close method)" do
      subject.should_receive(:on_close).with(subject.sndfile.path)
      subject.close_file
    end

  end

end
