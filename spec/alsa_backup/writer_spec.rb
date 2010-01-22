require File.dirname(__FILE__) + '/../spec_helper.rb'

describe AlsaBackup::Writer do

  before(:each) do
    @file = "test.wav"
    @directory = test_directory
    @writer = AlsaBackup::Writer.new :directory => @directory, :file => @file
  end

  describe "when created" do

    it "should use the :directory option as directory" do
      AlsaBackup::Writer.new(:directory => @directory).directory.should == @directory
    end

    it "should use the :file option as file" do
      AlsaBackup::Writer.new(:file => @file).file.should == @file
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

  describe "on_close" do
    
    it "should include a callback which delete empty file" do
      AlsaBackup::Writer.should_receive(:delete_empty_file).with(@file)
      @writer.on_close(@file)
    end

    it "should invoke all on_close_callbacks" do
      file_given_to_proc = nil

      @writer.on_close_callbacks << Proc.new do |file| 
        file_given_to_proc = file
      end
      @writer.on_close(@file)

      file_given_to_proc.should == @file
    end

    it "should ignore exception from callbacks" do
      @writer.on_close_callbacks << Proc.new do |file| 
        raise "Error"
      end
      lambda { @writer.on_close(@file) }.should_not raise_error
    end

  end

  describe "file" do
    
    it "should accept file as string" do
      @writer.file = file_name = "dummy"
      @writer.file.should == file_name
    end

    it "should accept file as Proc" do
      file_name = "dummy"
      @writer.file = Proc.new { file_name }
      @writer.file.should == file_name
    end
    
  end

  describe "rename_existing_file" do

    it "should keep file if not exists" do
      File.should_receive(:exists?).with(@file).and_return(false)
      File.should_not_receive(:rename)
      AlsaBackup::Writer.rename_existing_file(@file)
    end

    it "should try to suffix with '-n' to find a free name" do
      File.stub!(:exists?).and_return(true)

      free_file = File.suffix_basename(@file, "-99")
      File.should_receive(:exists?).with(free_file).and_return(false)

      File.should_receive(:rename).with(@file, free_file)
      AlsaBackup::Writer.rename_existing_file(@file)
    end

    it "should raise an error when no free file is found" do
      File.stub!(:exists?).and_return(true)
      lambda do
        AlsaBackup::Writer.rename_existing_file(@file)
      end.should raise_error
    end

  end

  describe "close" do

    it "should close file (via close_file method)" do
      @writer.should_receive(:close_file)
      @writer.close
    end
    
  end

  describe "close_file" do
    
    it "should close current sndfile" do
      sndfile = @writer.sndfile
      sndfile.should_receive(:close)
      @writer.close_file
    end

    it "should notify on_close callbacks (via on_close method)" do
      @writer.should_receive(:on_close).with(@writer.sndfile.path)
      @writer.close_file
    end

  end

end
