module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  #
  # File instance methods - called by CamcorderFS::File instances.
  # Methods are wraped in delegate class for camcorder interposition.
  #
  class CcDelegate
    #
    # File instance methods - implementation.
    #
    def file_i_atime(instance_handle)
      instance_call(:atime, instance_handle)
    end

    def file_i_chmod(instance_handle, permission)
      instance_call(:chmod, instance_handle, permission)
    end

    def file_i_chown(instance_handle, owner, group)
      instance_call(:chown, instance_handle, owner, group)
    end

    def file_i_ctime(instance_handle)
      instance_call(:ctime, instance_handle)
    end

    def file_i_flock(instance_handle, locking_constant)
      instance_call(:flock, instance_handle, locking_constant)
    end

    def file_i_lstat(instance_handle)
      VirtFS::Stat.new(instance_call(:lstat, instance_handle))
    end

    def file_i_mtime(instance_handle)
      instance_call(:mtime, instance_handle)
    end

    def file_i_size(instance_handle)
      instance_call(:size, instance_handle)
    end

    def file_i_truncate(instance_handle, to_size)
      instance_call(:truncate, instance_handle, to_size)
    end

    #
    # IO instance methods.
    #
    def file_i_close(instance_handle)
      instance_call(:close, instance_handle)
    end

    def file_i_close_on_exec?(instance_handle)
      instance_call(:close_on_exec?, instance_handle)
    end

    def file_i_close_on_exec=(instance_handle, bool_val)
      instance_call(:close_on_exec=, instance_handle, bool_val)
    end

    def file_i_close_read(instance_handle)
      instance_call(:close_read, instance_handle)
    end

    def file_i_close_write(instance_handle)
      instance_call(:close_write, instance_handle)
    end

    def file_i_fcntl(instance_handle, cmd, arg)
      instance_call(:fcntl, instance_handle, cmd, arg)
    end

    def file_i_fdatasync(instance_handle)
      instance_call(:fdatasync, instance_handle)
    end

    def file_i_fileno(instance_handle)
      instance_call(:fileno, instance_handle)
    end

    def file_i_flush(instance_handle)
      instance_call(:flush, instance_handle)
    end

    def file_i_fsync(instance_handle)
      instance_call(:fsync, instance_handle)
    end

    def file_i_ioctl(instance_handle, cms, arg)
      instance_call(:ioctl, instance_handle, cms, arg)
    end

    def file_i_isatty(instance_handle)
      instance_call(:isatty, instance_handle)
    end

    def file_i_pid(instance_handle)
      instance_call(:pid, instance_handle)
    end

    def file_i_raw_read(instance_handle, start_byte, num_bytes)
      instance_handle.sysseek(start_byte, IO::SEEK_SET)
      instance_handle.sysread(num_bytes)
    end

    def file_i_raw_write(instance_handle, start_byte, buf)
      instance_handle.sysseek(start_byte, IO::SEEK_SET)
      instance_handle.syswrite(buf)
    end

    def file_i_readpartial(instance_handle, limit, result)
      instance_call(:readpartial, instance_handle, limit, result)
    end

    def file_i_read_nonblock(instance_handle, limit, result)
      instance_call(:read_nonblock, instance_handle, limit, result)
    end

    def file_i_stat(instance_handle)
      VirtFS::Stat.new(instance_call(:stat, instance_handle))
    end

    def file_i_sync(instance_handle)
      instance_call(:sync, instance_handle)
    end

    def file_i_sync=(instance_handle, bool_val)
      instance_call(:sync=, instance_handle, bool_val)
    end

    def file_i_to_i(instance_handle)
      instance_call(:to_i, instance_handle)
    end

    def file_i_tty?(instance_handle)
      instance_call(:tty?, instance_handle)
    end

    def file_i_write_nonblock(instance_handle, buf)
      instance_call(:write_nonblock, instance_handle, buf)
    end
  end
end
