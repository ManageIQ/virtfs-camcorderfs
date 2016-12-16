module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  #
  # Directory instance methods - called by CamcorderFS::Dir instances - thick interface.
  # Makes recordable call to corresponding CcDelegate method.
  #
  class FS
    module DirInstanceMethods
      #
      # Dir instance methods - delegate to CcDelegate.
      #
      def dir_i_close(instance_handle)
        ccd_call(__method__, instance_handle)
      end

      def dir_i_each(instance_handle, block, rv)
        return_enum(ccd_call(__method__, instance_handle), block, rv)
      end
    end
  end
end
