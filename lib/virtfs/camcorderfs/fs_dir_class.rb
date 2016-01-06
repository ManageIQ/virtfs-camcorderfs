module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  #
  # Directory class methods - called by VirtFS::Dir.
  # Makes recordable call to corresponding CcDelegate method.
  #
  class FS
    def dir_delete(p)
      ccd_call(__method__, apply_root(p))
    end

    def dir_chdir(p)
      ccd_call(__method__, apply_root(p))
    end

    def dir_entries(p)
      ccd_call(__method__, apply_root(p))
    end

    def dir_exist?(p)
      ccd_call(__method__, apply_root(p))
    end

    def dir_foreach(p, &block)
      return_enum(dir_entries(p), block)
    end

    def dir_mkdir(p, permissions)
      ccd_call(__method__, apply_root(p), permissions)
    end

    def dir_new(fs_rel_path, hash_args, open_path, cwd)
      instance_handle = ccd_call(__method__, apply_root(fs_rel_path), hash_args, open_path, cwd)
      VirtFS::CamcorderFS::Dir.new(self, instance_handle, hash_args)
    end
  end
end
