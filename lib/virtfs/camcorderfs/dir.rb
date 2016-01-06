module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  #
  # CamcorderFS::Dir class.
  # Instance methods call into CamcorderFS::FS instance.
  #
  class Dir
    attr_reader :fs

    NS_PFX = "dir_i_"

    def initialize(fs, instance_handle, hash_args)
      @fs              = fs
      @instance_handle = instance_handle
      @hash_args       = hash_args
      @cache           = nil
    end

    def close
      fs_call(__method__)
    end

    # returns file_name and new position.
    def read(pos)
      return cache[pos], pos + 1
    end

    private

    def cache
      @cache ||= fs_call(:each, nil, nil).to_a
    end

    def fs_call(method, *args)
      @fs.send("#{NS_PFX}#{method}", @instance_handle, *args)
    end
  end
end
