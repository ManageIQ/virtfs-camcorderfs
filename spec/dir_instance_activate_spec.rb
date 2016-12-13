require 'spec_helper'

describe "CamcorderFS::Dir instance methods - VirtFS activated" do
  before(:all) do
    reset_context
 
    @full_path = File.expand_path(__FILE__)
    @rel_path  = File.basename(@full_path)
    @spec_dir  = File.dirname(@full_path)
    @this_dir  = VfsRealDir.getwd
    @root      = File::SEPARATOR

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

      describe "#close" do
        it "should return nil" do
          VirtFS.with do
            dir = Dir.new(@spec_dir)
            expect(dir.close).to be_nil
          end
        end

        it "should cause subsequent access to raise IOError: closed directory" do
          VirtFS.with do
            dir = Dir.new(@spec_dir)
            dir.close

            expect { dir.close     }.to raise_error(IOError, "closed directory")
            expect { dir.each.to_a }.to raise_error(IOError, "closed directory")
            expect { dir.pos = 0   }.to raise_error(IOError, "closed directory")
            expect { dir.read      }.to raise_error(IOError, "closed directory")
            expect { dir.rewind    }.to raise_error(IOError, "closed directory")
            expect { dir.seek(0)   }.to raise_error(IOError, "closed directory")
            expect { dir.tell      }.to raise_error(IOError, "closed directory")
          end
        end
      end

      describe "#each" do
        it "should return an enum when no block is given" do
          VirtFS.with do
            Dir.open(@spec_dir) { |dir| expect(dir.each).to be_kind_of(Enumerator) }
          end
        end

        it "should return the directory object when block is given" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              expect(dir.each { true }).to eq(dir)
            end
          end
        end

        it "should enumerate the same files as the standard Dir method" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir1|
              VfsRealDir.open(@spec_dir) do |dir2|
                expect(dir1.each.to_a).to match_array(dir2.each.to_a)
              end
            end
          end
        end
      end

      describe "#path #to_path" do
        it "should return full path when opened with full path" do
          VirtFS.with do
            Dir.open(@spec_dir) { |dir| expect(dir.path).to eq(@spec_dir) }
          end
        end
      
        it "should return relative path when opened with relative path" do
          parent, target_dir = VfsRealFile.split(@spec_dir)
          VirtFS.with do
            Dir.chdir(parent)
            Dir.open(target_dir) { |dir| expect(dir.path).to eq(target_dir) }
          end
        end
      end

      describe "#pos #tell" do
        it "should return the same value when the current position hasn't changed" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              expect(dir.pos).to eq(dir.pos)
            end
          end
        end

        it "should return a different value when the current position has changed" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              pos1 = dir.pos
              dir.read
              expect(dir.pos).to_not eq(pos1)
            end
          end
        end
      end

      describe "#pos=" do
        it "should return the passed value" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              (0..4).each { |p| expect(dir.pos = p).to eq(p) }
            end
          end
        end

        it "should not change the position when given a value not previously returned by #tell or #pos" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              pos0 = dir.pos
              dir.pos = pos0 + 1
              expect(dir.pos).to eq(pos0)
            end
          end
        end

        it "should change the position when given a value previously returned by #tell or #pos" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              pos0 = dir.pos
              dir.read
              pos1 = dir.pos
              expect(pos0).to_not eq(pos1)
              expect(dir.pos).to  eq(pos1)
              dir.pos = pos0
              expect(dir.pos).to  eq(pos0)
            end
          end
        end

        it "should change the position for subsequent reads" do
          reads_by_pos = {}
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              reads_by_pos[dir.pos] = dir.read
              dir.read
              dir.read
              reads_by_pos[dir.pos] = dir.read
              dir.read
              reads_by_pos[dir.pos] = dir.read

              reads_by_pos.each do |p, r|
                dir.pos = p
                expect(dir.read).to eq(r)
              end
            end
          end
        end
      end

      describe "#read" do
        it "should read successive directory entries, returning the same files as Dir#each" do
          dir_entries = []
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              while de = dir.read
                dir_entries << de
              end
            end

            VfsRealDir.open(@spec_dir) do |dir|
              expect(dir.each.to_a).to match_array(dir_entries)
            end
          end
        end

        it "should return nil when at end of directory" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              while (de = dir.read); end
              expect(dir.read).to be_nil
            end
          end
        end
      end

      describe "#rewind" do
        it "should return the directory object" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              expect(dir.rewind).to eq(dir)
            end
          end
        end

        it "should reset the current position so reading starts at the beginning" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              first_entry = dir.read
              while (de = dir.read); end
              expect(dir.read).to be_nil
              dir.rewind
              expect(dir.read).to eq(first_entry)
            end
          end
        end
      end

      describe "#seek" do
        it "should return the directory object" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              (0..4).each { |p| expect(dir.seek(p)).to eq(dir) }
            end
          end
        end

        it "should not change the position when given a value not previously returned by #tell or #pos" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              pos0 = dir.tell
              dir.seek(pos0 + 1)
              expect(dir.tell).to eq(pos0)
            end
          end
        end

        it "should change the position when given a value previously returned by #tell or #pos" do
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              pos0 = dir.tell
              dir.read
              pos1 = dir.tell
              expect(pos0).to_not eq(pos1)
              expect(dir.tell).to eq(pos1)
              dir.seek(pos0)
              expect(dir.tell).to eq(pos0)
            end
          end
        end

        it "should change the position for subsequent reads" do
          reads_by_pos = {}
          VirtFS.with do
            Dir.open(@spec_dir) do |dir|
              reads_by_pos[dir.tell] = dir.read
              dir.read
              dir.read
              reads_by_pos[dir.tell] = dir.read
              dir.read
              reads_by_pos[dir.tell] = dir.read

              reads_by_pos.each do |p, r|
                dir.seek(p)
                expect(dir.read).to eq(r)
              end
            end
          end
        end
      end
    end
  end
end
