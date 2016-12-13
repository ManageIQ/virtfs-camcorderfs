require 'spec_helper'

describe "CamcorderFS::File instance methods - VirtFS activated" do
  before(:all) do
    reset_context
    
    @spec_name   = VfsRealFile.basename(__FILE__, ".rb")
    @temp_prefix = "#{@spec_name}-"

    @ext        = ".rb"
    @data1      = "0123456789" * 4
    @temp_file  = Tempfile.new(["VirtFS-File", @ext])
    @temp_file.write(@data1)
    @temp_file.close
    @full_path  = @temp_file.path
    @rel_path   = File.basename(@full_path)
    @parent_dir = File.dirname(@full_path)
    @spec_dir   = File.dirname(__FILE__)

    @ext2        = ".c"
    @temp_file2  = Tempfile.new(["VirtFS-File", @ext2])
    @temp_file2.close
    @full_path2  = @temp_file2.path
    @rel_path2   = File.basename(@full_path2)
    @parent_dir2 = File.dirname(@full_path2)

    @slink_path  = temp_name(@temp_prefix, ".symlink")

    @this_dir   = VfsRealDir.getwd
    @root       = File::SEPARATOR

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
        VirtFS::VDir.chdir(@spec_dir)
      end

      describe "#atime" do
        it "should return a Time object" do
          VirtFS.with do
            File.open(@full_path) { |vf| expect(vf.atime).to be_kind_of(Time) }
          end
        end
      end

      describe "#chmod" do
        it "should return 0" do
          VirtFS.with do
            File.open(@full_path) do |vf|
              expect(vf.chmod(0777)).to eq(0)
            end
          end
        end

        it "should change the permission bits on the file" do
          target_mode = 0755
          VirtFS.with do
            expect(File.stat(@full_path).mode & 0777).to_not eq(target_mode)
            File.open(@full_path) do |vf|
              expect(vf.chmod(target_mode)).to be_zero
            end
            expect(File.stat(@full_path).mode & 0777).to eq(target_mode)
          end
        end
      end

      describe "#chown" do
        it "should return 0 on success" do
          stat = VfsRealFile.stat(@full_path)

          VirtFS.with do
            File.open(@full_path) do |vf|
              expect(vf.chown(stat.uid, stat.gid)).to eq(0)
            end
          end
        end
      end

      describe "#ctime" do
        it "should return a Time object" do
          VirtFS.with do
            File.open(@full_path) { |vf| expect(vf.ctime).to be_kind_of(Time) }
          end
        end
      end

      describe "#flock" do
        it "should return 0" do
          VirtFS.with do
            File.open(@full_path) do |vf|
              expect(vf.flock(File::LOCK_EX)).to eq(0)
            end
          end
        end
      end

      describe "#lstat" do
        before(:each) do
          VirtFS::VFile.symlink(@full_path, @slink_path)
        end

        after(:each) do
          VirtFS::VFile.delete(@slink_path)
        end

        it "should return the stat information for the symlink" do
          VirtFS.with do
            File.open(@slink_path) do |sl|
              expect(sl.lstat.symlink?).to be true
            end
          end
        end
      end

      describe "#mtime" do
        it "should return a Time object" do
          VirtFS.with do
            File.open(@full_path) { |vf| expect(vf.mtime).to be_kind_of(Time) }
          end
        end
      end

      describe "#path :to_path" do
        it "should return full path when opened with full path" do
          VirtFS.with do
            File.open(@full_path) { |f| expect(f.path).to eq(@full_path) }
          end
        end

        it "should return relative path when opened with relative path" do
          parent, target_file = VfsRealFile.split(@full_path)
          VirtFS.with do
            Dir.chdir(parent)
            File.open(target_file) { |f| expect(f.path).to eq(target_file) }
          end
        end
      end

      describe "#size" do
        it "should return the known size of the file" do
          VirtFS.with do
            File.open(@full_path) { |f| expect(f.size).to eq(@data1.bytesize) }
          end
        end
      end

      describe "#truncate" do
        it "should return 0" do
          VirtFS.with do
            File.open(@full_path, "w") { |f| expect(f.truncate(5)).to eq(0) }
          end
        end

        it "should raise IOError when file isn't open for writing" do
          VirtFS.with do
            File.open(@full_path, "r") do |f|
              expect { f.truncate(0) }.to raise_error(IOError, "not opened for writing")
            end
          end
        end

        it "should truncate the file to the specified size" do
          tsize = @data1.bytesize / 2
          VirtFS.with do
            expect(File.size(@full_path)).to_not eq(tsize)
            File.open(@full_path, "w") { |f| f.truncate(tsize) }
            expect(File.size(@full_path)).to eq(tsize)
          end
        end
      end
    end
  end
end
