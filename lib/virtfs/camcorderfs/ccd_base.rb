module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  class CcDelegate
    def instance_call(method, instance_handle, *args)
      instance_handle.send(method, *args)
    end
    private :instance_call
  end
end
