module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  #
  # Directory instance methods - called by CamcorderFS::Dir instances.
  # Methods are wraped in delegate class for camcorder interposition.
  #
  class CcDelegate
    module DirInstanceMethods
      #
      # Dir instance methods - implementation.
      #
      def dir_i_close(instance_handle)
        instance_call(:close, instance_handle)
      end

      def dir_i_each(instance_handle)
        instance_call(:each, instance_handle).to_a
      end
    end
  end
end
