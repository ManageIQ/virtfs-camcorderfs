require 'spec_helper'
require 'fileutils'
require 'tmpdir'

describe "CamcorderFS - File - different record and playback mount points" do
  before(:all) do
    reset_context

    @ext        = ".rb"
    @data1      = "0123456789" * 4
    @temp_file  = Tempfile.new(["VirtFS-File", @ext])
    @temp_file.write(@data1)
    @temp_file.close

    @temp_file_full_path = @temp_file.path
    @temp_file_basename  = File.basename(@temp_file_full_path)
    @temp_file_dirname   = File.dirname(@temp_file_full_path)

    @root      = File::SEPARATOR

    @tmp_dir_path   = VfsRealDir.mktmpdir("vfs_spec_tmp-") { |dp| dp }

    @native_fs  = nativefs_class.new
    VirtFS.mount(@native_fs,  @root)

    @recording_file = recording_file_name(__FILE__)
    VfsRealFile.delete(@recording_file) if VfsRealFile.exist?(@recording_file)
  end

  after(:all) do
    VirtFS.umount(@root)
    VfsRealFile.delete(@recording_file)
  end

  %w( Record Playback ).each do |mode|
    context "Mode: #{mode} -" do
      before(:all) do
        @cc_mount_point = VfsRealDir.mktmpdir("vfs_spec_mnt_#{mode}-")
        @cc_fs = VirtFS::CamcorderFS::FS.new(@recording_file)

        #
        # Mount @temp_file_dirname on @cc_mount_point through ccfs.
        #
        @cc_fs.root = @temp_file_dirname
        VirtFS.mount(@cc_fs,  @cc_mount_point)

        # Path to temp file through ccfs.
        @temp_file_mounted_path = File.join(@cc_mount_point, @temp_file_basename)
      end

      after(:all) do
        VirtFS.umount(@cc_mount_point)
        FileUtils.remove_dir(@cc_mount_point)
      end

      before(:each) do
        VfsRealDir.mkdir(@tmp_dir_path)
      end

      after(:each) do
        FileUtils.remove_dir(@tmp_dir_path) if VfsRealDir.exist?(@tmp_dir_path)
      end

      describe "#atime" do
        it "should return a Time object" do
          VirtFS::VFile.open(@temp_file_mounted_path) { |vf| expect(vf.atime).to be_kind_of(Time) }
        end
      end

      describe "#chmod" do
        it "should return 0" do
          VirtFS::VFile.open(@temp_file_mounted_path) do |vf|
            expect(vf.chmod(0777)).to eq(0)
          end
        end

        it "should change the permission bits on the file" do
          target_mode = 0755
          expect(VirtFS::VFile.stat(@temp_file_mounted_path).mode & 0777).to_not eq(target_mode)
          VirtFS::VFile.open(@temp_file_mounted_path) do |vf|
            expect(vf.chmod(target_mode)).to be_zero
          end
          expect(VirtFS::VFile.stat(@temp_file_mounted_path).mode & 0777).to eq(target_mode)
        end
      end

      describe "#chown" do
        it "should return 0 on success" do
          stat = VfsRealFile.stat(@temp_file_full_path)

          VirtFS::VFile.open(@temp_file_mounted_path) do |vf|
            expect(vf.chown(stat.uid, stat.gid)).to eq(0)
          end
        end
      end

      describe "#ctime" do
        it "should return a Time object" do
          VirtFS::VFile.open(@temp_file_mounted_path) { |vf| expect(vf.ctime).to be_kind_of(Time) }
        end
      end

      describe "#flock" do
        it "should return 0" do
          VirtFS::VFile.open(@temp_file_mounted_path) do |vf|
            expect(vf.flock(File::LOCK_EX)).to eq(0)
          end
        end
      end

      describe "#mtime" do
        it "should return a Time object" do
          VirtFS::VFile.open(@temp_file_mounted_path) { |vf| expect(vf.mtime).to be_kind_of(Time) }
        end
      end

      describe "#path :to_path" do
        it "should return full path when opened with full path" do
          VirtFS::VFile.open(@temp_file_mounted_path) { |f| expect(f.path).to eq(@temp_file_mounted_path) }
        end

        it "should return relative path when opened with relative path" do
          VirtFS::VDir.chdir(@cc_mount_point) do
            VirtFS::VFile.open(@temp_file_basename) { |f| expect(f.path).to eq(@temp_file_basename) }
          end
        end
      end

      describe "#size" do
        it "should return the known size of the file" do
          VirtFS::VFile.open(@temp_file_mounted_path) { |f| expect(f.size).to eq(@data1.bytesize) }
        end
      end

      describe "#truncate" do
        it "should return 0" do
          VirtFS::VFile.open(@temp_file_mounted_path, "w") { |f| expect(f.truncate(5)).to eq(0) }
        end

        it "should raise IOError when file isn't open for writing" do
          VirtFS::VFile.open(@temp_file_mounted_path, "r") do |f|
            expect { f.truncate(0) }.to raise_error(IOError, "not opened for writing")
          end
        end

        it "should truncate the file to the specified size" do
          tsize = @data1.bytesize / 2
          expect(VirtFS::VFile.size(@temp_file_mounted_path)).to_not eq(tsize)
          VirtFS::VFile.open(@temp_file_mounted_path, "w") { |f| f.truncate(tsize) }
          expect(VirtFS::VFile.size(@temp_file_mounted_path)).to eq(tsize)
        end
      end
    end # context: mode
  end # each mode
end
