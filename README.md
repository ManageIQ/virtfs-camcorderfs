# VirtFS/CamcorderFS

A pseudo filesystem plugin for the **VirtFS** infrastructure, that provides the ability to record/playback all filesystem activity that is performed through a given mount point.

## Installation

Add this line to your application's Gemfile:

```ruby
gem 'virtfs-comcorderfs'
```

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install virtfs-comcorderfs

## Usage

The **virtfs-comcorderfs** enables the user to _mount_ a given directory of the native filesystem on a virtual mount point within the **virtfs** infrastructure. Once mounted, all filesystem operations performed through the virtual mount point are recorded or played back as follows:

When a `VirtFS::CamcorderFS::FS` instance is instantiated, it is passed the loaction of the recording (cassette) file to be used.

* When the cassette file doesn't exist, the `VirtFS::CamcorderFS::FS` instance is in **record** mode. Once mounted, the instance will **record** all filesystem activity performed through the virtual mount point.

* When the cassette file does exist `VirtFS::CamcorderFS::FS` instance is in **playback** mode. Once mounted, the instance will **playback** all filesystem activity recorded to the cassette file, bypassing native file system access.

This capability is very useful in developing automated tests that rely on specific aspects of the filesystem that may not be available in the automated test environment (like Travis).

For example, say your tests require access to an NFS share or a block special file. Chances are, the share or special file in question will not be accessible in the Travis environment. The **virtfs-comcorderfs** plugin provides a solution to this problem similar to the solutions provided by the **VCR** and **camcorder** gems. In fact, as the name implies, **virtfs-comcorderfs** uses the **camcorder** gem to perform record/playback.

So, the tests are first run in the base test environemnt, the cassette files are recorded and committed along with the tests. When the tests are run within the Travis environemnt, the filesystem interactions are played back from the cassette files, eliminating the need to access the aspects of the filesystem that are not available in the Travis environemnt.

```ruby
require "virtfs-nativefs-thick"
require "virtfs-comcorderfs"

# Instantiate an instance of the native filesystem.
native_fs = VirtFS::NativeFS::Thick.new

# Mount the native filesystem on root "/"
VirtFS.mount(native_fs, "/")

# Instantiate an instance of CamcorderFS, specifying the cassette file.
cc_fs = VirtFS::CamcorderFS::FS.new(@recording_file)

#
# Mount /dev of the native filesystem on /dev of
# the VirtFS namespace, through CamcorderFS.
#
cc_fs.root = "/dev"
VirtFS.mount(cc_fs, "/dev")

VirtFS.with do
  #
  # Access files under /dev as needed.
  # Interactions are recorded/played back.
  #
end

VirtFS.umount("/dev")
```

## Contributing 

1. Fork it
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request

## License

The gem is available as open source under the terms of the [MIT License](http://opensource.org/licenses/MIT).

