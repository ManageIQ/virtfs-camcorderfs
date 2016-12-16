require_relative 'cc_delegate/dir_class_methods'
require_relative 'cc_delegate/dir_instance_methods'
require_relative 'cc_delegate/file_class_methods'
require_relative 'cc_delegate/file_instance_methods'

module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  class CcDelegate
    include DirClassMethods
    include DirInstanceMethods
    include FileClassMethods
    include FileInstanceMethods

    def instance_call(method, instance_handle, *args)
      instance_handle.send(method, *args)
    end
    private :instance_call
  end
end
