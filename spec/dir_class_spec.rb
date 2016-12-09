require 'spec_helper'
require 'fileutils'
require 'tmpdir'

describe "CamcorderFS::Dir class methods" do
  before(:all) do
    reset_context

    @full_path = File.expand_path(__FILE__)
    @rel_path  = File.basename(@full_path)
    @spec_dir  = File.dirname(@full_path)
    @this_dir  = VfsRealDir.getwd
    @root      = File::SEPARATOR

    @tmp_dir_path = VfsRealDir.mktmpdir("vfs_spec_tmp-") { |dp| dp }

    @recording_file = recording_file_name(__FILE__)
    VfsRealFile.delete(@recording_file) if VfsRealFile.exist?(@recording_file)
  end

  after(:all) do
    VfsRealFile.delete(@recording_file)
  end

  %w( Record Playback ).each do |mode|
    context "Mode: #{mode}" do
      before(:all) do
        @cc_fs = VirtFS::CamcorderFS::FS.new(@recording_file)
        VirtFS.mount(@cc_fs, @root)
      end

      after(:all) do
        VirtFS.umount(@root)
      end

      before(:each) do
        VirtFS::VDir.chdir(@this_dir)
      end

      after(:each) do
        FileUtils.remove_dir(@tmp_dir_path) if VfsRealDir.exist?(@tmp_dir_path)
      end

      describe ".[]" do
        it "should return empty array when in a nonexistent directory" do
          VirtFS.cwd = "/not_a_dir" # bypass existence checks.
          expect(VirtFS::VDir["*"]).to match_array([])
        end

        it "should enumerate the same file names as the standard Dir.glob - simple glob" do
          VfsRealDir.chdir(@this_dir) do # for VfsRealDir.glob
            VirtFS.dir_chdir(@this_dir)
            expect(VirtFS::VDir["*"]).to match_array(VfsRealDir["*"])
            expect(VirtFS::VDir["*/*.rb"]).to match_array(VfsRealDir["*/*.rb"])
          end
        end

        it "should enumerate the same file names as the standard Dir.glob - relative glob" do
          VfsRealDir.chdir(@spec_dir) do # for VfsRealDir.glob
            VirtFS.dir_chdir(@spec_dir)
            expect(VirtFS::VDir["../**/*.rb"] - VfsRealDir["../**/*.rb"]).to match_array([])
          end
        end
      end

      describe ".chdir" do
        it "should raise Errno::ENOENT when directory doesn't exist" do
          expect do
            VirtFS::VDir.chdir("nonexistent_directory")
          end.to raise_error(
            Errno::ENOENT, "No such file or directory - nonexistent_directory"
          )
        end

        it "should return 0 when no block given" do
          expect(VirtFS::VDir.chdir(@this_dir)).to eq(0)
        end

        it "should return last object of block, when block given" do
          expect(VirtFS::VDir.chdir(@this_dir) { |_path| true }).to be true
        end

        it "should yield the new current directory to the block" do
          expect(VirtFS::VDir.chdir(@this_dir) { |path| path == @this_dir }).to be true
        end

        it "should change to the home directory when called without an argument" do
          VirtFS::VDir.chdir
          expect(VirtFS::VDir.getwd).to eq(VfsRealDir.home)
        end
      end

      describe ".delete .rmdir .unlink" do
        it "should raise Errno::ENOENT when directory does not exist in the native FS" do
          expect do
            VirtFS::VDir.delete("/not_a_dir/foo.d")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should delete the directory - given full path" do
          VfsRealDir.mkdir(@tmp_dir_path)
          dir_path = VfsRealFile.join(@tmp_dir_path, "foo.d")
          expect(VirtFS::VDir.mkdir(dir_path)).to eq(0)
          expect(VirtFS::VDir.exist?(dir_path)).to be true
          expect(VirtFS::VDir.delete(dir_path)).to eq(0)
          expect(VirtFS::VDir.exist?(dir_path)).to be false
        end

        it "should delete the directory - given relative path" do
          VfsRealDir.mkdir(@tmp_dir_path)
          dir_path = VfsRealFile.join(@tmp_dir_path, "foo.d")
          VirtFS::VDir.chdir(@tmp_dir_path)
          expect(VirtFS::VDir.mkdir("foo.d")).to eq(0)
          expect(VirtFS::VDir.exist?(dir_path)).to be true
          expect(VirtFS::VDir.delete("foo.d")).to eq(0)
          expect(VirtFS::VDir.exist?(dir_path)).to be false
        end
      end

      describe ".entries" do
        before(:each) do
          VirtFS.dir_chdir(@this_dir)
        end

        it "should raise Errno::ENOENT when given a nonexistent directory" do
          expect do
            VirtFS::VDir.entries("nonexistent_directory")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should, given full path, return the same file names as the real Dir.entries" do
          expect(VirtFS::VDir.entries(@this_dir)).to eq(VfsRealDir.entries(@this_dir))
        end

        it "should, given relative path, return the same file names as the real Dir.entries" do
          expect(VirtFS::VDir.entries(".")).to eq(VfsRealDir.entries("."))
        end
      end

      describe ".exist? .exists?" do
        before(:each) do
          VirtFS.dir_chdir(@this_dir)
        end

        it "should, given full path, return true for this directory" do
          expect(VirtFS::VDir.exist?(@this_dir)).to be true
        end

        it "should, given relative path, return true for this directory" do
          expect(VirtFS::VDir.exist?(".")).to be true
        end
      end

      describe ".foreach" do
        before(:each) do
          VirtFS.dir_chdir(@this_dir)
        end

        it "should raise Errno::ENOENT when given a nonexistent directory" do
          expect do
            VirtFS::VDir.foreach("nonexistent_directory").to_a
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return an enum when no block is given" do
          expect(VirtFS::VDir.foreach(@this_dir)).to be_kind_of(Enumerator)
        end

        it "should return nil when block is given" do
          expect(VirtFS::VDir.foreach(@this_dir) { |f| f }).to be_nil
        end

        it "should, given full path, return the same file names as the real Dir.foreach" do
          expect(VirtFS::VDir.foreach(@this_dir).to_a).to eq(VfsRealDir.foreach(@this_dir).to_a)
        end

        it "should, given relative path, return the same file names as the real Dir.foreach" do
          expect(VirtFS::VDir.foreach(".").to_a).to eq(VfsRealDir.foreach(".").to_a)
        end
      end

      describe ".glob" do
        it "should return empty array when in a nonexistent directory" do
          VirtFS.cwd = "/not_a_dir" # bypass existence checks.
          expect(VirtFS::VDir.glob("*")).to match_array([])
        end

        it "should enumerate the same file names as the standard Dir.glob - simple glob" do
          VfsRealDir.chdir(@this_dir) do # for VfsRealDir.glob
            VirtFS.dir_chdir(@this_dir)
            expect(VirtFS::VDir.glob("*")).to eq(VfsRealDir.glob("*"))
            expect(VirtFS::VDir.glob("*/*.rb")).to eq(VfsRealDir.glob("*/*.rb"))
          end
        end

        it "should enumerate the same file names as the standard Dir.glob - relative glob" do
          VfsRealDir.chdir(@spec_dir) do # for VfsRealDir.glob
            VirtFS.dir_chdir(@spec_dir)
            expect(VirtFS::VDir.glob("../**/*.rb") - VfsRealDir.glob("../**/*.rb")).to match_array([])
          end
        end
      end

      describe ".mkdir" do
        it "should raise Errno::ENOENT when parent does exist in the native FS" do
          expect do
            VirtFS::VDir.mkdir("/not_a_dir/foo.d")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should create the directory in the parent directory - given full path" do
          VfsRealDir.mkdir(@tmp_dir_path)
          dir_path = VfsRealFile.join(@tmp_dir_path, "foo.d")
          expect(VirtFS::VDir.mkdir(dir_path)).to eq(0)
          expect(VirtFS::VDir.exist?(dir_path)).to be true
        end

        it "should create the directory in the parent directory - given relative path" do
          VfsRealDir.mkdir(@tmp_dir_path)
          dir_path = VfsRealFile.join(@tmp_dir_path, "foo.d")
          VirtFS::VDir.chdir(@tmp_dir_path)
          expect(VirtFS::VDir.mkdir("foo.d")).to eq(0)
          expect(VirtFS::VDir.exist?(dir_path)).to be true
        end
      end

      describe ".new" do
        it "should raise Errno::ENOENT when directory doesn't exist" do
          expect do
            VirtFS::VDir.new("/not_a_dir")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return a directory object - given full path" do
          expect(VirtFS::VDir.new(@this_dir)).to be_kind_of(VirtFS::VDir)
        end

        it "should return a directory object - given relative path" do
          VfsRealDir.mkdir(@tmp_dir_path)
          VirtFS::VDir.chdir(@tmp_dir_path)
          expect(VirtFS::VDir.mkdir("foo.d")).to eq(0)
          expect(VirtFS::VDir.new("foo.d")).to be_kind_of(VirtFS::VDir)
        end
      end

      describe ".open" do
        it "should raise Errno::ENOENT when directory doesn't exist" do
          expect do
            VirtFS::VDir.new("/not_a_dir")
          end.to raise_error(
            Errno::ENOENT # , /No such file or directory/
          )
        end

        it "should return a directory object - when no block given" do
          expect(VirtFS::VDir.open(@this_dir)).to be_kind_of(VirtFS::VDir)
        end

        it "should yield a directory object to the block - when block given" do
          VirtFS::VDir.open(@this_dir) { |dir_obj| expect(dir_obj).to be_kind_of(VirtFS::VDir) }
        end

        it "should return the value of the block - when block given" do
          expect(VirtFS::VDir.open(@this_dir) { true }).to be true
        end
      end
    end
  end
end
