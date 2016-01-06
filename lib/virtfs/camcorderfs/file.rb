module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  #
  # CamcorderFS::File class.
  # Instance methods call into CamcorderFS::FS instance.
  #
  class File
    attr_reader :fs

    NS_PFX = "file_i_"

    def initialize(fs, instance_handle, parsed_args)
      @fs              = fs
      @instance_handle = instance_handle
      @parsed_args     = parsed_args
    end

    #
    # File instance methods.
    #
    def atime
      fs_call(__method__)
    end

    def chmod(permission)
      fs_call(__method__, permission)
    end

    def chown(owner, group)
      fs_call(__method__, owner, group)
    end

    def ctime
      fs_call(__method__)
    end

    def flock(locking_constant)
      fs_call(__method__, locking_constant)
    end

    def lstat
      fs_call(__method__)
    end

    def mtime
      fs_call(__method__)
    end

    def size
      fs_call(__method__)
    end

    def truncate(to_size)
      fs_call(__method__, to_size)
    end

    #
    # IO instance methods.
    #
    def close
      fs_call(__method__)
    end

    def close_on_exec?
      fs_call(__method__)
    end

    def close_on_exec=(bool_val)
      fs_call(__method__, bool_val)
    end

    def close_read
      fs_call(__method__)
    end

    def close_write
      fs_call(__method__)
    end

    def fcntl(cmd, arg)
      fs_call(__method__, cmd, arg)
    end

    def fdatasync
      fs_call(__method__)
    end

    def fileno
      fs_call(__method__)
    end

    def flush
      fs_call(__method__)
    end

    def fsync
      fs_call(__method__)
    end

    def ioctl(cms, arg)
      fs_call(__method__, cms, arg)
    end

    def isatty
      fs_call(__method__)
    end

    def pid
      fs_call(__method__)
    end

    def raw_read(start_byte, num_bytes)
      fs_call(__method__, start_byte, num_bytes)
    end

    def raw_write(start_byte, buf)
      fs_call(__method__, start_byte, buf)
    end

    def readpartial(limit, result = "")
      fs_call(__method__, limit, result)
    end

    def read_nonblock(limit, result = "")
      fs_call(__method__, limit, result)
    end

    def stat
      fs_call(__method__)
    end

    def sync
      fs_call(__method__)
    end

    def sync=(bool_val)
      fs_call(__method__, bool_val)
    end

    def to_i
      fs_call(__method__)
    end

    def tty?
      fs_call(__method__)
    end

    def write_nonblock(buf)
      fs_call(__method__, buf)
    end

    private

    def fs_call(method, *args)
      @fs.send("#{NS_PFX}#{method}", @instance_handle, *args)
    end
  end
end
