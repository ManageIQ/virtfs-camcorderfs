require 'spec_helper'

#
# Class methods.
#
describe "CamcorderFS::File class methods" do
  before(:all) do
    reset_context

    @spec_name = VfsRealFile.basename(__FILE__, ".rb")
    @temp_prefix = "#{@spec_name}-"

    @time = Time.new(2015, 9, 12, 9, 50)

    @start_marker = "START OF FILE:\n"
    @end_marker   = ":END OF FILE"
    @data1        = "0123456789"
    @data2        = "abcdefghijklmnopqrstuvwzyz\n"

    @data_args = {
      :start_marker => @start_marker,
      :end_marker   => @end_marker,
      :data1        => @data1,
      :data2        => @data2,
    }

    @ext        = ".rb"
    @temp_file  = Tempfile.new(["VirtFS-File", @ext])
    @full_path  = @temp_file.path
    @temp_file.close
    @rel_path   = File.basename(@full_path)
    @parent_dir = File.dirname(@full_path)

    @ext2        = ".c"
    @temp_file2  = Tempfile.new(["VirtFS-File", @ext2])
    @full_path2  = @temp_file2.path
    @temp_file2.close
    @rel_path2   = File.basename(@full_path2)
    @parent_dir2 = File.dirname(@full_path2)

    @slink_path  = temp_name(@temp_prefix, ".symlink")
    @link_path   = temp_name(@temp_prefix, ".hardlink")
    @to_path     = temp_name(@temp_prefix, ".renamed")

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
        @file1_size = write_test_file(VfsRealFile, @full_path,  @data_args)
        VfsRealFile.chown(Process.uid, Process.gid, @full_path)
        VfsRealFile.open(@full_path2, "w") {}
        VirtFS::VDir.chdir(@this_dir)
      end

      after(:each) do
        VfsRealFile.delete(@full_path)   if VfsRealFile.exist?(@full_path)
        VfsRealFile.delete(@full_path2)  if VfsRealFile.exist?(@full_path2)
      end

      # after(:each) do
      #   FileUtils.remove_dir(@tmp_dir_path) if VfsRealDir.exist?(@tmp_dir_path)
      # end

      describe ".atime" do
        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.atime("nonexistent_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return a Time object, when given full path" do
          expect(VirtFS::VFile.atime(@full_path)).to be_kind_of(Time)
        end

        it "should return a Time object, when given relative path" do
          VirtFS.dir_chdir(@parent_dir)
          expect(VirtFS::VFile.atime(@rel_path)).to be_kind_of(Time)
        end
      end

      describe ".basename" do
        it "should return the same value as the standard File.basename" do
          expect(VirtFS::VFile.basename(@full_path)).to eq(VfsRealFile.basename(@full_path))
        end
      end

      describe ".blockdev?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.blockdev?("nonexistent_file")).to be false
        end

        it "should return false when given a non-blockdev file" do
          expect(VirtFS::VFile.blockdev?(@full_path)).to be false
        end

        it "should return true when given a blockdev file" do
          expect(bdev = block_dev_file).to_not eq(nil)
          expect(VirtFS::VFile.blockdev?(bdev)).to be true
        end
      end

      describe ".chardev?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.chardev?("nonexistent_file")).to be false
        end

        it "should return false when given a non-chardev file" do
          expect(VirtFS::VFile.chardev?(@full_path)).to be false
        end

        it "should return true when given a chardev file" do
          expect(cdev = char_dev_file).to_not eq(nil)
          expect(VirtFS::VFile.chardev?(cdev)).to be true
        end
      end

      describe ".chmod" do
        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.chmod(0755, "nonexistent_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return the number of files processed" do
          expect(VirtFS::VFile.chmod(0777, @full_path)).to eq(1)
          expect(VirtFS::VFile.chmod(0777, @full_path, @full_path2)).to eq(2)
        end

        it "should change the permission bits on an existing file" do
          target_mode = 0755
          expect(VirtFS::VFile.stat(@full_path).mode & 0777).to_not eq(target_mode)
          VirtFS::VFile.chmod(target_mode, @full_path)
          expect(VirtFS::VFile.stat(@full_path).mode & 0777).to eq(target_mode)
        end
      end

      describe ".chown" do
        before(:each) do
          stat = VfsRealFile.stat(@full_path)
          @owner = stat.uid
          @group = stat.gid
        end

        it "should return the number of files processed" do
          expect(VirtFS::VFile.chown(@owner, @group, @full_path)).to eq(1)
          expect(VirtFS::VFile.chown(@owner, @group, @full_path, @full_path2)).to eq(2)
        end
      end

      describe ".ctime" do
        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.ctime("nonexistent_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return a Time object, when given full path" do
          expect(VirtFS::VFile.ctime(@full_path)).to be_kind_of(Time)
        end

        it "should return a Time object, when given relative path" do
          VirtFS.dir_chdir(@parent_dir)
          expect(VirtFS::VFile.ctime(@rel_path)).to be_kind_of(Time)
        end
      end

      describe ".delete" do
        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.delete("nonexistent_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return the number of files processed - 1" do
          expect(VirtFS::VFile.delete(@full_path)).to eq(1)
        end

        it "should return the number of files processed - 2" do
          expect(VirtFS::VFile.delete(@full_path, @full_path2)).to eq(2)
        end

        it "should delete an existing file" do
          expect(VirtFS::VFile.exist?(@full_path)).to be true
          VirtFS::VFile.delete(@full_path)
          expect(VirtFS::VFile.exist?(@full_path)).to_not be true
        end
      end

      describe ".directory?" do
        it "should return false when given a nonexistent directory" do
          expect(VirtFS::VFile.directory?("nonexistent_directory")).to be false
        end

        it "should return false when given a regular file" do
          expect(VirtFS::VFile.directory?(@full_path)).to be false
        end

        it "should return true when given a directory" do
          expect(VirtFS::VFile.directory?(@parent_dir)).to be true
        end
      end

      describe ".executable?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.executable?("nonexistent_file")).to be false
        end

        it "should return false when given a non-executable file" do
          expect(VirtFS::VFile.executable?(@full_path)).to be false
        end

        it "should return true when given a executable file" do
          VirtFS::VFile.chmod(0100, @full_path)
          expect(VirtFS::VFile.executable?(@full_path)).to be true
        end
      end

      describe ".executable_real?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.executable_real?("nonexistent_file")).to be false
        end

        it "should return false when given a non-executable file" do
          expect(VirtFS::VFile.executable_real?(@full_path)).to be false
        end

        it "should return true when given a executable file" do
          VirtFS::VFile.chmod(0100, @full_path)
          expect(VirtFS::VFile.executable_real?(@full_path)).to be true
        end
      end

      describe ".exist?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.exist?("nonexistent_directory")).to be false
        end

        it "should return true when given a regular file" do
          expect(VirtFS::VFile.exist?(@full_path)).to be true
        end

        it "should return true when given a directory" do
          expect(VirtFS::VFile.exist?(@parent_dir)).to be true
        end
      end

      describe ".expand_path" do
        it "should return the same path as the standard File.expand_path, when given a dirstring" do
          expect(VirtFS::VFile.expand_path(@rel_path, @parent_dir)).to eq(VfsRealFile.expand_path(@rel_path, @parent_dir))
        end

        it "should return the same path as the standard File.expand_path, when using pwd" do
          VfsRealDir.chdir(@parent_dir) do
            VirtFS.cwd = VfsRealDir.getwd
            expect(VirtFS::VFile.expand_path(@rel_path)).to eq(VfsRealFile.expand_path(@rel_path))
          end
        end
      end

      describe ".extname" do
        it "should return the known extension of tempfile 1" do
          expect(VirtFS::VFile.extname(@full_path)).to eq(@ext)
        end

        it "should return the known extension of tempfile 2" do
          expect(VirtFS::VFile.extname(@full_path2)).to eq(@ext2)
        end
      end

      describe ".file?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.file?("nonexistent_directory")).to be false
        end

        it "should return true when given a regular file" do
          expect(VirtFS::VFile.file?(@full_path)).to be true
        end

        it "should return false when given a directory" do
          expect(VirtFS::VFile.file?(@parent_dir)).to be false
        end
      end

      describe ".fnmatch" do
        it "should match representative examples" do
          expect(VirtFS::VFile.fnmatch('cat', 'cat')).to                               be true
          expect(VirtFS::VFile.fnmatch('cat', 'category')).to                          be false
          expect(VirtFS::VFile.fnmatch('c?t', 'cat')).to                               be true
          expect(VirtFS::VFile.fnmatch('c\?t', 'cat')).to                              be false
          expect(VirtFS::VFile.fnmatch('c??t', 'cat')).to                              be false
          expect(VirtFS::VFile.fnmatch('c*', 'cats')).to                               be true
          expect(VirtFS::VFile.fnmatch('c/**/t', 'c/a/b/c/t')).to                      be true
          expect(VirtFS::VFile.fnmatch('c**t', 'c/a/b/c/t')).to                        be true
          expect(VirtFS::VFile.fnmatch('c**t', 'cat')).to                              be true
          expect(VirtFS::VFile.fnmatch('**.txt', 'notes.txt')).to                      be true
          expect(VirtFS::VFile.fnmatch('**.txt', 'some/dir/tree/notes.txt')).to        be true
          expect(VirtFS::VFile.fnmatch('c*t', 'cat')).to                               be true
          expect(VirtFS::VFile.fnmatch('c\at', 'cat')).to                              be true
          expect(VirtFS::VFile.fnmatch('c\at', 'cat', File::FNM_NOESCAPE)).to          be false
          expect(VirtFS::VFile.fnmatch('a?b', 'a/b')).to                               be true
          expect(VirtFS::VFile.fnmatch('a?b', 'a/b', File::FNM_PATHNAME)).to           be false
          expect(VirtFS::VFile.fnmatch('*', '.profile')).to                            be false
          expect(VirtFS::VFile.fnmatch('*', '.profile', File::FNM_DOTMATCH)).to        be true
          expect(VirtFS::VFile.fnmatch('*', 'dave/.profile')).to                       be true
          expect(VirtFS::VFile.fnmatch('*', 'dave/.profile', File::FNM_DOTMATCH)).to   be true
          expect(VirtFS::VFile.fnmatch('*', 'dave/.profile', File::FNM_PATHNAME)).to   be false
          expect(VirtFS::VFile.fnmatch('*/*', 'dave/.profile', File::FNM_PATHNAME)).to be false
          strict = File::FNM_PATHNAME | File::FNM_DOTMATCH
          expect(VirtFS::VFile.fnmatch('*/*', 'dave/.profile', strict)).to             be true
        end
      end

      describe ".ftype" do
        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.ftype("nonexistent_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return 'file' when given a regular file" do
          expect(VirtFS::VFile.ftype(@full_path)).to eq('file')
        end

        it "should return 'directory' when given a directory" do
          expect(VirtFS::VFile.ftype(@parent_dir)).to eq('directory')
        end

        it "should return 'blockSpecial,' when given a block device file" do
          expect(bdev = block_dev_file).to_not eq(nil)
          expect(VirtFS::VFile.ftype(bdev)).to eq('blockSpecial')
        end

        it "should return 'characterSpecial,' when given a block device file" do
          expect(cdev = char_dev_file).to_not eq(nil)
          expect(VirtFS::VFile.ftype(cdev)).to eq('characterSpecial')
        end
      end

      describe ".grpowned?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.grpowned?("nonexistent_file")).to be false
        end

        it "should return true when given a file we created" do
          expect(VirtFS::VFile.grpowned?(@full_path)).to be true
        end
      end

      describe ".identical?" do
        before(:each) do
          VfsRealFile.symlink(@full_path, @slink_path)
        end

        after(:each) do
          VfsRealFile.delete(@slink_path)
        end

        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.identical?(@full_path, "nonexistent_file1")).to be false
        end

        it "should return true when given the same file" do
          expect(VirtFS::VFile.identical?(@full_path, @full_path)).to be true
        end

        it "should return true when given a file and its symlink" do
          expect(VirtFS::VFile.identical?(@full_path, @slink_path)).to be true
        end
      end

      describe ".join" do
        it "should return the same path as the standard File.join" do
          dirs = %( dir1 dir2 dir3 dir4 dir5 )
          expect(VirtFS::VFile.join(dirs)).to eq(VfsRealFile.join(dirs))
        end
      end

      if VfsRealFile.respond_to?(:lchmod)
        describe ".lchmod" do
          it "should raise Errno::ENOENT when given a nonexistent file" do
            expect do
              VirtFS::VFile.lchmod(0755, "nonexistent_file")
            end.to raise_error(
              Errno::ENOENT, /No such file or directory/
            )
          end

          it "should return the number of files processed" do
            expect(VirtFS::VFile.lchmod(0777, @full_path)).to eq(1)
            expect(VirtFS::VFile.lchmod(0777, @full_path, @full_path2)).to eq(2)
          end

          it "should change the permission bits on an existing file" do
            target_mode = 0755
            expect(VirtFS::VFile.stat(@full_path).mode & 0777).to_not eq(target_mode)
            VirtFS::VFile.lchmod(target_mode, @full_path)
            expect(VirtFS::VFile.stat(@full_path).mode & 0777).to eq(target_mode)
          end
        end
      end

      describe ".lchown" do
        before(:each) do
          stat = VfsRealFile.stat(@full_path)
          @owner = stat.uid
          @group = stat.gid

          VfsRealFile.symlink(@full_path, @slink_path)
        end

        after(:each) do
          VfsRealFile.delete(@slink_path)
        end

        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.lchown(@owner, @group, "nonexistent_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return the number of files processed" do
          expect(VirtFS::VFile.lchown(@owner, @group, @slink_path)).to eq(1)
          expect(VirtFS::VFile.lchown(@owner, @group, @slink_path, @full_path2)).to eq(2)
        end
      end

      describe ".link" do
        after(:each) do
          VfsRealFile.delete(@link_path) if VfsRealFile.exist?(@link_path)
        end

        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.link("nonexistent_file1", @link_path)
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return 0 on success" do
          expect(VirtFS::VFile.link(@full_path, @link_path)).to eq(0)
        end

        it "the link should be identical to the original file" do
          expect(VirtFS::VFile.link(@full_path, @link_path)).to eq(0)
          expect(VirtFS::VFile.identical?(@full_path, @link_path)).to be true
        end
      end

      describe ".lstat" do
        before(:each) do
          VfsRealFile.symlink(@full_path, @slink_path)
        end

        after(:each) do
          VfsRealFile.delete(@slink_path)
        end

        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.lstat("nonexistent_file1")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return the stat information for the symlink" do
          expect(VirtFS::VFile.lstat(@slink_path).symlink?).to be true
        end
      end

      describe ".mtime" do
        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.mtime("nonexistent_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return a Time object, when given full path" do
          expect(VirtFS::VFile.mtime(@full_path)).to be_kind_of(Time)
        end

        it "should return a Time object, when given relative path" do
          VirtFS.dir_chdir(@parent_dir)
          expect(VirtFS::VFile.mtime(@rel_path)).to be_kind_of(Time)
        end
      end

      describe ".owned?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.owned?("nonexistent_file")).to be false
        end

        it "should return true when given a file we created" do
          expect(VirtFS::VFile.owned?(@full_path)).to be true
        end
      end

      describe ".path" do
        it "should work with a string" do
          expect(VirtFS::VFile.path(@full_path)).to eq(@full_path)
        end

        it "should work with an IO object" do
          VirtFS::VFile.open(@full_path) do |fobj|
            expect(VirtFS::VFile.path(fobj)).to eq(@full_path)
          end
        end
      end

      describe ".pipe?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.pipe?("nonexistent_file")).to be false
        end

        it "should return false when given a regular file" do
          expect(VirtFS::VFile.pipe?(@full_path)).to be false
        end
      end

      describe ".readable?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.readable?("nonexistent_file")).to be false
        end

        it "should return false when given a non-readable file" do
          VirtFS::VFile.chmod(0300, @full_path)
          expect(VirtFS::VFile.readable?(@full_path)).to be false
        end

        it "should return true when given a readable file" do
          VirtFS::VFile.chmod(0400, @full_path)
          expect(VirtFS::VFile.readable?(@full_path)).to be true
        end
      end

      describe ".readable_real?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.readable_real?("nonexistent_file")).to be false
        end

        it "should return false when given a non-readable file" do
          VirtFS::VFile.chmod(0300, @full_path)
          expect(VirtFS::VFile.readable_real?(@full_path)).to be false
        end

        it "should return true when given a readable file" do
          VirtFS::VFile.chmod(0400, @full_path)
          expect(VirtFS::VFile.readable_real?(@full_path)).to be true
        end
      end

      describe ".readlink" do
        before(:each) do
          VfsRealFile.symlink(@full_path, @slink_path)
        end

        after(:each) do
          VfsRealFile.delete(@slink_path)
        end

        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.readlink("nonexistent_file1")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return the stat information for the symlink" do
          expect(VirtFS::VFile.readlink(@slink_path)).to eq(@full_path)
        end
      end

      describe ".realdirpath" do
        it "should return the same path as the standard realdirpath" do
          expect(VirtFS::VFile.realdirpath(@full_path)).to eq(VfsRealFile.realdirpath(@full_path))
        end
      end

      describe ".realpath" do
        it "should return the same path as the standard realdirpath" do
          expect(VirtFS::VFile.realpath(@full_path)).to eq(VfsRealFile.realpath(@full_path))
        end
      end

      describe ".rename" do
        after(:each) do
          VfsRealFile.delete(@to_path) if VfsRealFile.exist?(@to_path)
        end

        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.rename("nonexistent_file1", "something")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return 0 on success" do
          expect(VirtFS::VFile.rename(@full_path, @to_path)).to eq(0)
        end

        it "the link should rename the file" do
          expect(VirtFS::VFile.rename(@full_path, @to_path)).to eq(0)
          expect(VirtFS::VFile.exist?(@to_path)).to be true
          expect(VirtFS::VFile.exist?(@full_path)).to be false
        end
      end

      describe ".setgid?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.setgid?("nonexistent_file")).to be false
        end

        it "should return false when given a non-setgid file" do
          VfsRealFile.chmod(0644, @full_path)
          expect(VirtFS::VFile.setgid?(@full_path)).to be false
        end

        it "should return true when given a setgid file" do
          VfsRealFile.chmod(02644, @full_path)
          expect(VirtFS::VFile.setgid?(@full_path)).to be true
        end
      end

      describe ".setuid?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.setuid?("nonexistent_file")).to be false
        end

        it "should return false when given a non-setuid file" do
          VfsRealFile.chmod(0644, @full_path)
          expect(VirtFS::VFile.setuid?(@full_path)).to be false
        end

        it "should return true when given a setuid file" do
          VfsRealFile.chmod(04644, @full_path)
          expect(VirtFS::VFile.setuid?(@full_path)).to be true
        end
      end

      describe ".size" do
        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.size("nonexistent_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return the known size of the file" do
          expect(VirtFS::VFile.size(@full_path)).to eq(@file1_size)
        end

        it "should return the same value as the standard File#size" do
          expect(VirtFS::VFile.size(@full_path)).to eq(VfsRealFile.size(@full_path))
        end

        it "should return 0 for empty file" do
          expect(VirtFS::VFile.size(@full_path2)).to eq(0)
        end
      end

      describe ".size?" do
        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.size?("nonexistent_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return the known size of the file" do
          expect(VirtFS::VFile.size?(@full_path)).to eq(@file1_size)
        end

        it "should return the same value as the standard File#size" do
          expect(VirtFS::VFile.size?(@full_path)).to eq(VfsRealFile.size?(@full_path))
        end

        it "should return nil for empty file" do
          expect(VirtFS::VFile.size?(@full_path2)).to eq(nil)
        end
      end

      describe ".socket?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.socket?("nonexistent_file")).to be false
        end

        it "should return false when given a regular file" do
          expect(VirtFS::VFile.socket?(@full_path)).to be false
        end
      end

      describe "::split" do
        it "should return the same values as the standard File.split" do
          expect(VirtFS::VFile.split(@full_path)).to match_array(VfsRealFile.split(@full_path))
        end
      end

      describe ".stat" do
        before(:each) do
          VfsRealFile.symlink(@full_path, @slink_path)
        end

        after(:each) do
          VfsRealFile.delete(@slink_path)
        end

        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.stat("nonexistent_file1")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return the stat information for the file" do
          expect(VirtFS::VFile.stat(@full_path).symlink?).to be false
        end

        it "given a symlink, should return the stat information for the regular file" do
          expect(VirtFS::VFile.stat(@slink_path).symlink?).to be false
        end
      end

      describe ".sticky?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.sticky?("nonexistent_file")).to be false
        end

        it "should return false when given a non-sticky file" do
          VfsRealFile.chmod(0644, @full_path)
          expect(VirtFS::VFile.sticky?(@full_path)).to be false
        end

        it "should return true when given a sticky file" do
          VfsRealFile.chmod(01644, @full_path)
          expect(VirtFS::VFile.sticky?(@full_path)).to be true
        end
      end

      describe ".symlink" do
        after(:each) do
          VirtFS::VFile.delete(@slink_path) if VirtFS::VFile.exist?(@slink_path)
        end

        it "should return 0 on success" do
          expect(VirtFS::VFile.symlink(@full_path, @slink_path)).to eq(0)
        end

        it "the symlink should be identical to the original file" do
          expect(VirtFS::VFile.symlink(@full_path, @slink_path)).to eq(0)
          expect(VirtFS::VFile.identical?(@full_path, @slink_path)).to be true
        end
      end

      describe ".symlink?" do
        before(:each) do
          VfsRealFile.symlink(@full_path, @slink_path)
        end

        after(:each) do
          VfsRealFile.delete(@slink_path)
        end

        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.symlink?("nonexistent_file")).to be false
        end

        it "should return true given a symlink" do
          expect(VirtFS::VFile.symlink?(@slink_path)).to be true
        end
      end

      describe ".truncate" do
        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.truncate("nonexistent_file", 0)
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return 0" do
          expect(VirtFS::VFile.truncate(@full_path, 5)).to eq(0)
        end

        it "should raise truncate the file to the specified size" do
          tsize = @file1_size / 2
          expect(VirtFS::VFile.size(@full_path)).to_not eq(tsize)
          VirtFS::VFile.truncate(@full_path, tsize)
          expect(VirtFS::VFile.size(@full_path)).to eq(tsize)
        end
      end

      describe "::umask" do
        it "should do something"
      end

      describe ".utime" do
        it "should raise Errno::ENOENT when given a nonexistent file" do
          expect do
            VirtFS::VFile.utime(@time, @time, "nonexistent_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should set the atime and mtime of the file, given a full path" do
          expect(VirtFS::VFile.utime(@time, @time, @full_path)).to eq(1)
          expect(VirtFS::VFile.atime(@full_path)).to eq(@time)
          expect(VirtFS::VFile.mtime(@full_path)).to eq(@time)
        end

        it "should set the atime and mtime of the file, given relative path" do
          VfsRealDir.chdir(@parent_dir) do
            VirtFS.dir_chdir(@parent_dir)
            expect(VirtFS::VFile.utime(@time, @time, @rel_path)).to eq(1)
            expect(VirtFS::VFile.atime(@full_path)).to eq(@time)
            expect(VirtFS::VFile.mtime(@full_path)).to eq(@time)
          end
        end
      end

      describe ".world_readable?" do
        it "should return nil when given a nonexistent file" do
          expect(VirtFS::VFile.world_readable?("nonexistent_file")).to eq(nil)
        end

        it "should return nil when given a non-world-readable file" do
          VirtFS::VFile.chmod(0773, @full_path)
          expect(VirtFS::VFile.world_readable?(@full_path)).to eq(nil)
        end

        it "should return permission bits when given a world-readable file" do
          VirtFS::VFile.chmod(0004, @full_path)
          expect(VirtFS::VFile.world_readable?(@full_path)).to eq(0004)
        end
      end

      describe ".world_writable?" do
        it "should return nil when given a nonexistent file" do
          expect(VirtFS::VFile.world_writable?("nonexistent_file")).to eq(nil)
        end

        it "should return nil when given a non-world_writable file" do
          VirtFS::VFile.chmod(0775, @full_path)
          expect(VirtFS::VFile.world_writable?(@full_path)).to eq(nil)
        end

        it "should return permission bits when given a world_writable file" do
          VirtFS::VFile.chmod(0002, @full_path)
          expect(VirtFS::VFile.world_writable?(@full_path)).to eq(0002)
        end
      end

      describe ".writable?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.writable?("nonexistent_file")).to be false
        end

        it "should return false when given a non-writable file" do
          VirtFS::VFile.chmod(0500, @full_path)
          expect(VirtFS::VFile.writable?(@full_path)).to be false
        end

        it "should return true when given a writable file" do
          VirtFS::VFile.chmod(0200, @full_path)
          expect(VirtFS::VFile.writable?(@full_path)).to be true
        end
      end

      describe ".writable_real?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.writable_real?("nonexistent_file")).to be false
        end

        it "should return false when given a non-writable file" do
          VirtFS::VFile.chmod(0500, @full_path)
          expect(VirtFS::VFile.writable_real?(@full_path)).to be false
        end

        it "should return true when given a writable file" do
          VirtFS::VFile.chmod(0200, @full_path)
          expect(VirtFS::VFile.writable_real?(@full_path)).to be true
        end
      end

      describe ".zero?" do
        it "should return false when given a nonexistent file" do
          expect(VirtFS::VFile.zero?("nonexistent_file")).to be false
        end

        it "should return false when given a non-zero length file" do
          expect(VirtFS::VFile.zero?(@full_path)).to be false
        end

        it "should return true when given a zero length file" do
          expect(VirtFS::VFile.zero?(@full_path2)).to be true
        end
      end

      describe ".new" do
        it "should raise Errno::ENOENT when the file doesn't exist" do
          expect do
            VirtFS::VFile.new("not_a_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return a File object - given full path" do
          expect(VirtFS::VFile.new(@full_path)).to be_kind_of(VirtFS::VFile)
        end

        it "should return a directory object - given relative path" do
          VirtFS::VDir.chdir(@parent_dir)
          expect(VirtFS::VFile.new(@rel_path)).to be_kind_of(VirtFS::VFile)
        end
      end

      describe ".open" do
        it "should raise Errno::ENOENT when file doesn't exist" do
          expect do
            VirtFS::VFile.new("not_a_file")
          end.to raise_error(
            Errno::ENOENT, /No such file or directory/
          )
        end

        it "should return a File object - when no block given" do
          expect(VirtFS::VFile.open(@full_path)).to be_kind_of(VirtFS::VFile)
        end

        it "should yield a file object to the block - when block given" do
          VirtFS::VFile.open(@full_path) { |file_obj| expect(file_obj).to be_kind_of(VirtFS::VFile) }
        end

        it "should return the value of the block - when block given" do
          expect(VirtFS::VFile.open(@full_path) { true }).to be true
        end
      end
    end
  end
end
