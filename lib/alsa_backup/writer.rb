require 'sndfile'
require 'fileutils'

module AlsaBackup
  class Writer

    attr_accessor :directory, :file, :format, :on_close_callbacks

    def self.default_format
      {:sample_rate => 44100, :channels => 2, :format => "wav pcm_16"}
    end

    def initialize(options = {})
      options = { 
        :format => Writer.default_format 
      }.update(options)

      @directory = options[:directory]
      @file = options[:file]
      @format = options[:format]

      @on_close_callbacks = []
      @on_close_callbacks << options[:on_close] if options[:on_close]
    end

    def self.open(options, &block)
      writer = Writer.new(options)
      begin
        writer.prepare
        yield writer
      ensure
        writer.close
      end
    end

    def prepare
      # prepare sndfile
      self.sndfile
      self
    end

    def write(*arguments)
      self.sndfile.write *arguments
    end

    def close
      close_file
    end

    def close_file
      if @sndfile
        @first_file_closed = true
        on_close(@sndfile.path)
        @sndfile.close
      end
      @sndfile = nil
    end

    def on_close(file)
      AlsaBackup.logger.info('close current file')
      return if Writer.delete_empty_file(file)

      AlsaBackup.logger.debug("invoke #{@on_close_callbacks.size} callback(s)")
      @on_close_callbacks.each do |callback|
        begin
          callback.call(file) 
        rescue Exception => e
          AlsaBackup.logger.error("error in on_close callback : #{e}")
          AlsaBackup.logger.debug { e.backtrace.join("\n") }
        end
      end
    end

    def first_file?
      not @first_file_closed
    end

    def file
      case @file
      when Proc
        @file.call first_file?
      else
        @file
      end
    end

    def target_file
      File.join self.directory, self.file
    end

    def sndfile
      target_file = self.target_file
      raise "no recording file" unless target_file

      unless @sndfile and @sndfile.path == target_file
        close_file
        # target_file can change when first_file_closed changes
        target_file = self.target_file

        Writer.rename_existing_file(target_file)
        AlsaBackup.logger.info{"new file #{File.expand_path target_file}"}

        FileUtils.mkdir_p File.dirname(target_file)
        @sndfile = Sndfile::File.new(target_file, "w", self.format)
      end
      @sndfile
    end

    def self.delete_empty_file(file)
      if File.exists?(file) and File.size(file) <= 44
        AlsaBackup.logger.warn("remove empty file #{file}")
        File.delete file
      end
    end

    def self.rename_existing_file(file)
      if File.exists?(file)
        index = 1

        while File.exists?(new_file = File.suffix_basename(file, "-#{index}"))
          index += 1

          raise "can't find a free file for #{file}" if index > 1000
        end

        AlsaBackup.logger.warn "rename existing file #{File.basename(file)} into #{new_file}"
        File.rename(file, new_file)
      end
    end

  end
end
