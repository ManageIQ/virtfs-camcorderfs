module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  #
  # File class methods - called by VirtFS::File.
  # Makes recordable call to corresponding CcDelegate method.
  #
  class FS
    module FileClassMethods
      def file_atime(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_blockdev?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_chardev?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_chmod(permission, p)
        ccd_call(__method__, permission, apply_root(p))
      end

      def file_chown(owner, group, p)
        ccd_call(__method__, owner, group, apply_root(p))
      end

      def file_ctime(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_delete(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_directory?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_executable?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_executable_real?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_exist?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_file?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_ftype(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_grpowned?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_identical?(p1, p2)
        ccd_call(__method__, apply_root(p1), apply_root(p2))
      end

      def file_lchmod(permission, p)
        ccd_call(__method__, permission, apply_root(p))
      end

      def file_lchown(owner, group, p)
        ccd_call(__method__, owner, group, apply_root(p))
      end

      def file_link(p1, p2)
        ccd_call(__method__, apply_root(p1), apply_root(p2))
      end

      def file_lstat(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_mtime(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_owned?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_pipe?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_readable?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_readable_real?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_readlink(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_rename(p1, p2)
        ccd_call(__method__, apply_root(p1), apply_root(p2))
      end

      def file_setgid?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_setuid?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_size(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_socket?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_stat(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_sticky?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_symlink(oname, p)
        #
        # We don't apply_root to oname, because it's either an
        # absolute path in the global FS namespace, or a path
        # relative to the location of the new link.
        #
        ccd_call(__method__, oname, apply_root(p))
      end

      def file_symlink?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_truncate(p, len)
        ccd_call(__method__, apply_root(p), len)
      end

      def file_utime(atime, mtime, p)
        ccd_call(__method__, atime, mtime, apply_root(p))
      end

      def file_world_readable?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_world_writable?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_writable?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_writable_real?(p)
        ccd_call(__method__, apply_root(p))
      end

      def file_new(fs_rel_path, parsed_args, open_path, cwd)
        instance_handle = ccd_call(__method__, apply_root(fs_rel_path), parsed_args, open_path, cwd)
        VirtFS::CamcorderFS::File.new(self, instance_handle, parsed_args)
      end
    end
  end
end
