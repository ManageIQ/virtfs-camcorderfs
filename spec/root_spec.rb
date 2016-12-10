require 'spec_helper'
require 'fileutils'
require 'tmpdir'

describe "CamcorderFS mount sub-dir on sub-dir" do
  before(:all) do
    reset_context

    @full_path = File.expand_path(__FILE__)
    @rel_path  = File.basename(@full_path)
    @spec_dir  = File.dirname(@full_path)
    @this_dir  = VfsRealDir.getwd
    @root      = File::SEPARATOR

    @cc_mount_point = VfsRealDir.mktmpdir("vfs_spec_mnt-")
    @tmp_dir_path   = VfsRealDir.mktmpdir("vfs_spec_tmp-") { |dp| dp }

    @native_fs  = nativefs_class.new
    VirtFS.mount(@native_fs,  @root)

    @recording_file = recording_file_name(__FILE__)
    VfsRealFile.delete(@recording_file) if VfsRealFile.exist?(@recording_file)
  end

  after(:all) do
    VirtFS.umount(@root)
    FileUtils.remove_dir(@cc_mount_point)
    VfsRealFile.delete(@recording_file)
  end

  %w( Record Playback ).each do |mode|
    context "Mode: #{mode} -" do
      before(:all) do
        expect(VirtFS::VDir.exist?(@cc_mount_point)).to be true
        expect(VirtFS::VDir.entries(@cc_mount_point).length).to eq(2)
        @cc_fs = VirtFS::CamcorderFS::FS.new(@recording_file)
        VirtFS.mount(@cc_fs,  @cc_mount_point)
        expect(VirtFS::VDir.exist?(@cc_mount_point)).to be true
      end

      after(:all) do
        VirtFS.umount(@cc_mount_point)
      end

      before(:each) do
        VfsRealDir.mkdir(@tmp_dir_path)
      end

      after(:each) do
        FileUtils.remove_dir(@tmp_dir_path) if VfsRealDir.exist?(@tmp_dir_path)
      end

      context "Read access" do
        it "directory entries should match" do
          # mounting @spec_dir as CamcorderFS, under @cc_mount_point
          @cc_fs.root = @spec_dir
          expect(VirtFS::VDir.entries(@cc_mount_point)).to match_array(VirtFS::VDir.entries(@spec_dir))
        end

        it "should be able to dynamically change mounted directory" do
          # First - mount @spec_dir as CamcorderFS, under @cc_mount_point
          @cc_fs.root = @spec_dir
          expect(VirtFS::VDir.entries(@cc_mount_point)).to match_array(VirtFS::VDir.entries(@spec_dir))

          # Then - mount @root as CamcorderFS, under @cc_mount_point
          @cc_fs.root = @root
          expect(VirtFS::VDir.entries(@cc_mount_point)).to match_array(VirtFS::VDir.entries(@root))
        end
      end

      context "Write access" do
        it "should be able to create directory tree through mount" do
          # Directory should be empty.
          expect(VirtFS::VDir.entries(@tmp_dir_path).length).to eq(2)

          # Mount @tmp_dir_path as CamcorderFS, under @cc_mount_point
          @cc_fs.root = @tmp_dir_path

          # View directory through mount point.
          VirtFS::VDir.chdir(@cc_mount_point) do
            mk_dir_tree(VirtFS::VDir, "Dir1", 4, 3)
            expect(check_dir_tree(VirtFS::VDir, "Dir1", 4, 3)).to be_nil
          end
        end

        it "Created directories should appear in the mounted directory" do
          # Directory should be empty.
          expect(VirtFS::VDir.entries(@tmp_dir_path).length).to eq(2)

          # Mount @tmp_dir_path as CamcorderFS, under @cc_mount_point
          @cc_fs.root = @tmp_dir_path

          # View directory through mount point.
          VirtFS::VDir.chdir(@cc_mount_point) do
            mk_dir_tree(VirtFS::VDir, "Dir1", 4, 3)
            expect(check_dir_tree(VirtFS::VDir, "Dir1", 4, 3)).to be_nil
          end

          # View directory directly.
          VirtFS::VDir.chdir(@tmp_dir_path) do
            if mode == "Record"
              expect(check_dir_tree(VirtFS::VDir, "Dir1", 4, 3)).to be_nil
            else # Playback
              #
              # On playback, we don't really create the tree, so we
              # shouldn't see it when not viewing the directory through
              # the CamcorderFS mount point.
              #
              expect do
                check_dir_tree(VirtFS::VDir, "Dir1", 4, 3)
              end.to raise_error(
                RuntimeError, "Expected directory Dir1 does not exist"
              )
            end
          end
        end
      end
    end # context: mode
  end # each mode
end
