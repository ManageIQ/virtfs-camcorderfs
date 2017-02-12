#
# Dir class methods - are instance methods of filesystem instance.
#
module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  #
  # Directory class methods - called by CamcorderFS::FS.
  # Methods are wraped in delegate class for camcorder interposition.
  #
  class CcDelegate
    module DirClassMethods
      def dir_chdir(_p)
        0 # needed for side effects.
      end

      def dir_delete(p)
        VfsRealDir.delete(p)
      end

      def dir_entries(p)
        VfsRealDir.entries(p)
      end

      def dir_exist?(p)
        VfsRealDir.exist?(p)
      end

      def dir_foreach(p)
        VfsRealDir.foreach(p).to_a
      end

      def dir_mkdir(p, permissions)
        VfsRealDir.mkdir(p, permissions)
      end

      def dir_new(fs_rel_path, hash_args, _open_path, cwd)
        owd = VfsRealDir.getwd
        begin
          VfsRealDir.chdir(cwd)
          return marshallable_dir(RealDir.new(fs_rel_path, hash_args))
        ensure
          VfsRealDir.chdir(owd)
        end
      end

      def marshallable_dir(dir)
        dir.instance_variable_set(:@__cc_id, dir.object_id)
        dir
      end
    end
  end
end
