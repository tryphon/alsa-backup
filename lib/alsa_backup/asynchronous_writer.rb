require 'sndfile'
require 'fileutils'

module AlsaBackup
  class AsynchronousWriter

    def initialize(options = {})
      @writer = Writer.new(options)
      @queue = Queue.new
    end

    def self.open(options, &block)
      writer = AsynchronousWriter.new(options)
      begin
        writer.prepare
        yield writer
      ensure
        writer.close
      end
    end

    def close
      @closed = true
      @writer.close
    end

    def write(buffer, frame_count)
      @queue << [ buffer, frame_count ]
    end

    def consume
      AlsaBackup.logger.debug { "Queue size: #{@queue.size}" }

      buffer, frame_count = @queue.pop
      @writer.write buffer, frame_count
    end

    def prepare
      @writer.prepare

      Thread.new do
        while not @closed do
          consume
        end
      end
    end

  end
end
