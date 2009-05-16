require 'rubygems'
require 'ffi'

include FFI

def try_to(message, &block)
  puts message
  if (response = yield) < 0
    raise "cannot #{message} (#{ALSA::Native::strerror(err)})"
  else
    response
  end
end

module ALSA
  module Native
    extend FFI::Library
    ffi_lib "libasound.so"

    attach_function :strerror, :snd_strerror, [:int], :string
  end

  module PCM

    class Capture

      attr_accessor :handle

      def open(device)
        capture_handle = MemoryPointer.new :pointer
        try_to "open audio device #{device}" do
          ALSA::PCM::Native::open capture_handle, device, ALSA::PCM::Native::STREAM_CAPTURE, ALSA::PCM::Native::BLOCK
        end
        self.handle = capture_handle.read_pointer

        if block_given?
          begin
            yield self 
          ensure
            self.close
          end
        end
      end

      def change_hardware_parameters
        hw_params = HwPameters.new(self)
        begin
          yield hw_params
          self.hardware_parameters = hw_params
        ensure
          hw_params.free
        end
      end

      def hardware_parameters=(hw_params)
        try_to "set hw parameters" do
          ALSA::PCM::Native::hw_params self.handle, hw_params.handle
        end
      end

      def read
        # TODO use real data to calculate buffer size
        frame_count = 44100
        format = ALSA::PCM::Native::FORMAT_S16_LE
        
        buffer = MemoryPointer.new(ALSA::PCM::Native::format_size(format, frame_count) * 2)

        continue = true
        while continue
          read_count = try_to "read from audio interface" do
            ALSA::PCM::Native::readi(self.handle, buffer, frame_count)
          end

          raise "can't read expected frame count (#{read_count}/#{frame_count})" unless read_count == frame_count
          
          continue = yield buffer, read_count
        end

        buffer.free
      end

      def close
        try_to "close audio device" do
          ALSA::PCM::Native::close self.handle
        end
      end

      class HwPameters

        attr_accessor :handle, :device

        def initialize(device = nil)
          hw_params_pointer = MemoryPointer.new :pointer
          ALSA::PCM::Native::hw_params_malloc hw_params_pointer        
          self.handle = hw_params_pointer.read_pointer

          self.device = device if device
        end

        def device=(device)
          try_to "initialize hardware parameter structure" do
            ALSA::PCM::Native::hw_params_any device.handle, self.handle
          end
          @device = device
        end

        def access=(access)
          try_to "set access type" do
            ALSA::PCM::Native::hw_params_set_access self.device.handle, self.handle, access
          end
        end

        def channels=(channels)
          try_to "set channel count : #{channels}" do
            ALSA::PCM::Native::hw_params_set_channels self.device.handle, self.handle, channels
          end
        end

        def sample_rate=(sample_rate)
          try_to "set sample rate" do
            rate = MemoryPointer.new(:int)
            rate.write_int(sample_rate)

            dir = MemoryPointer.new(:int)
            dir.write_int(0)

            error_code = ALSA::PCM::Native::hw_params_set_rate_near self.device.handle, self.handle, rate, dir

            rate.free
            dir.free

            error_code
          end
        end

        def sample_format=(sample_format)
          try_to "set sample format" do
            ALSA::PCM::Native::hw_params_set_format self.device.handle, self.handle, sample_format
          end
        end

        def free
          try_to "unallocate hw_params" do
            ALSA::PCM::Native::hw_params_free self.handle
          end
        end

      end

    end

    module Native
      extend FFI::Library
      ffi_lib "libasound.so"

      STREAM_CAPTURE = 1
      BLOCK = 0
      attach_function :open, :snd_pcm_open, [:pointer, :string, :int, :int], :int
      attach_function :prepare, :snd_pcm_prepare, [ :pointer ], :int
      attach_function :close, :snd_pcm_close, [:pointer], :int

      attach_function :readi, :snd_pcm_readi, [ :pointer, :pointer, :ulong ], :long

      attach_function :hw_params_malloc, :snd_pcm_hw_params_malloc, [:pointer], :int
      attach_function :hw_params_free, :snd_pcm_hw_params_free, [:pointer], :int

      attach_function :hw_params, :snd_pcm_hw_params, [ :pointer, :pointer ], :int
      attach_function :hw_params_any, :snd_pcm_hw_params_any, [:pointer, :pointer], :int

      ACCESS_RW_INTERLEAVED = 3
      attach_function :hw_params_set_access, :snd_pcm_hw_params_set_access, [ :pointer, :pointer, :int ], :int

      FORMAT_S16_LE = 2
      attach_function :hw_params_set_format, :snd_pcm_hw_params_set_format, [ :pointer, :pointer, :int ], :int
      attach_function :hw_params_set_rate_near, :snd_pcm_hw_params_set_rate_near, [ :pointer, :pointer, :pointer, :pointer ], :int
      attach_function :hw_params_set_channels, :snd_pcm_hw_params_set_channels, [ :pointer, :pointer, :uint ], :int
      attach_function :hw_params_set_periods, :snd_pcm_hw_params_set_periods, [ :pointer, :pointer, :uint, :int ], :int

      attach_function :format_size, :snd_pcm_format_size, [ :int, :uint ], :int
    end
  end
end