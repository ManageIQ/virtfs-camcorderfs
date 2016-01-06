module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  #
  # File instance methods - called by CamcorderFS::File instances - thick interface.
  # Makes recordable call to corresponding CcDelegate method.
  #
  class FS
    #
    # File instance methods - delegate to CcDelegate.
    #
    def file_i_atime(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_chmod(instance_handle, permission)
      ccd_call(__method__, instance_handle, permission)
    end

    def file_i_chown(instance_handle, owner, group)
      ccd_call(__method__, instance_handle, owner, group)
    end

    def file_i_ctime(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_flock(instance_handle, locking_constant)
      ccd_call(__method__, instance_handle, locking_constant)
    end

    def file_i_lstat(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_mtime(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_size(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_truncate(instance_handle, to_size)
      ccd_call(__method__, instance_handle, to_size)
    end

    #
    # IO instance methods.
    #
    def file_i_close(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_close_on_exec?(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_close_on_exec=(instance_handle, bool_val)
      ccd_call(__method__, instance_handle, bool_val)
    end

    def file_i_close_read(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_close_write(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_fcntl(instance_handle, cmd, arg)
      ccd_call(__method__, instance_handle, cmd, arg)
    end

    def file_i_fdatasync(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_fileno(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_flush(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_fsync(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_ioctl(instance_handle, cms, arg)
      ccd_call(__method__, instance_handle, cms, arg)
    end

    def file_i_isatty(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_pid(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_raw_read(instance_handle, start_byte, num_bytes)
      rv = ccd_call(__method__, instance_handle, start_byte, num_bytes)
      rv.force_encoding('ASCII-8BIT') # Needed when loaded from YAML.
    end

    def file_i_raw_write(instance_handle, start_byte, buf)
      ccd_call(__method__, instance_handle, start_byte, buf)
    end

    def file_i_readpartial(instance_handle, limit, result)
      ccd_call(__method__, instance_handle, limit, result)
    end

    def file_i_read_nonblock(instance_handle, limit, result)
      ccd_call(__method__, instance_handle, limit, result)
    end

    def file_i_stat(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_sync(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_sync=(instance_handle, bool_val)
      ccd_call(__method__, instance_handle, bool_val)
    end

    def file_i_to_i(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_tty?(instance_handle)
      ccd_call(__method__, instance_handle)
    end

    def file_i_write_nonblock(instance_handle, buf)
      ccd_call(__method__, instance_handle, buf)
    end
  end
end
