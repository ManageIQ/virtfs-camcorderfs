require_relative 'fs/dir_class_methods'
require_relative 'fs/dir_instance_methods'
require_relative 'fs/file_class_methods'
require_relative 'fs/file_instance_methods'

module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  class FS
    attr_accessor :mount_point, :name, :root
    attr_reader   :recording_path

    include DirClassMethods
    include DirInstanceMethods
    include FileClassMethods
    include FileInstanceMethods

    def initialize(recording_path = nil, root = VfsRealFile::SEPARATOR)
      @mount_point  = nil
      @name         = self.class.name
      @root         = root

      if recording_path.nil?
        @cc_delegate = CcDelegate.new
      else
        start_recorder(recording_path)
      end
    end

    def start_recorder(recording_path)
      @recording_path = recording_path
      @recorder       = Camcorder::Recorder.new(@recording_path)

      @cc_delegate = Camcorder.proxy_class(CcDelegate, @recorder) do
        #
        # Dir class methods.
        #
        methods_with_side_effects :dir_chdir, :dir_delete, :dir_mkdir, :dir_new

        #
        # Dir instance methods.
        #
        methods_with_side_effects :dir_i_close, :dir_i_each

        #
        # File class methods.
        #
        methods_with_side_effects :file_atime,  :file_chmod,    :file_chown,    :file_ctime,
                                  :file_delete, :file_lchmod,   :file_lchown,   :file_link,
                                  :file_lstat,  :file_mtime,    :file_new,      :file_rename,
                                  :file_stat,   :file_symlink?, :file_symlink,  :file_truncate,
                                  :file_utime

        #
        # File instance methods.
        #
        methods_with_side_effects :file_i_atime,          :file_i_chmod,       :file_i_chown,
                                  :file_i_ctime,          :file_i_flock,       :file_i_lstat,
                                  :file_i_mtime,          :file_i_truncate,    :file_i_close,
                                  :file_i_close_on_exec=, :file_i_close_read,  :file_i_close_write,
                                  :file_i_fcntl,          :file_i_ioctl,       :file_i_raw_read,
                                  :file_i_raw_write,      :file_i_readpartial, :file_i_read_nonblock,
                                  :file_i_write_nonblock
      end.new

      @recorder.start
    end

    def thin_interface?
      true
    end

    def umount
      @recorder.commit unless @recorder.nil?
      @mount_point = nil
    end

    def apply_root(path)
      VfsRealFile.join(@root, path)
    end
    private :apply_root

    def ccd_call(method, *args)
      @cc_delegate.send(method, *args)
    rescue SystemCallError => scerr
      #
      # The errno is lost when the exception is YAML.dump'd but the
      # sub-class is correct. We get the errno from the sub-class
      # and instantiate a new exception to raise.
      #
      # Passing the whole message from the original exception isn't
      # the right thing to do. We need to find a way to extract the
      # target name from the original message.
      #
      raise SystemCallError.new(scerr.message, scerr.class::Errno)
    rescue
      raise
    end
    private :ccd_call

    def return_enum(array, block, rv = nil)
      return array.each if block.nil? # return Enumerator.
      array.each(&block)
      rv
    end
    private :return_enum
  end
end
