require 'spec_helper'
require 'io_bufferio_encoding_shared_examples'

describe "CamcorderFS::IO bufferio methods w/encoding" do
  before(:all) do
    reset_context
    
    @data_dir        = VfsRealFile.join(__dir__, "data")
    @utf_8_filename  = VfsRealFile.join(@data_dir, "UTF-8-data.txt")
    @utf_16_filename = VfsRealFile.join(@data_dir, "UTF-16LE-data.txt")

    @start_marker = "START OF FILE:\n"
    @end_marker   = ":END OF FILE"
    @data1        = "0123456789"
    @data2        = "abcdefghijklmnopqrstuvwzyz\n"

    @temp_file    = Tempfile.new("VirtFS-IO")
    @temp_file.write(@start_marker)
    (0..9).each do
      @temp_file.write(@data1)
      @temp_file.write(@data2)
    end
    @temp_file.write(@end_marker)
    @temp_file.close

    @full_path  = @temp_file.path
    @file_size  = VfsRealFile.size(@full_path)

    @temp_write = Tempfile.new("VirtFS-IO")
    @temp_write.close
    @write_file_path = @temp_write.path

    @default_encoding = Encoding.default_external
    @binary_encoding  = Encoding.find("ASCII-8BIT")

    @spec_dir = File.dirname(__FILE__)
    @root = File::SEPARATOR

    @recording_file = recording_file_name(__FILE__)
    VfsRealFile.delete(@recording_file) if VfsRealFile.exist?(@recording_file)
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
        @vfile_read_obj  = VirtFS::VFile.new(@full_path, "r")
        @vfile_write_obj = VirtFS::VFile.new(@write_file_path, "w")
      end

      after(:each) do
        @vfile_read_obj.close  unless @vfile_read_obj.closed?
        @vfile_write_obj.close unless @vfile_write_obj.closed?
      end

      describe "#bytes" do # deprecated
        before(:each) do
          @rfile_obj = VfsRealFile.new(@full_path, "r")
        end

        after(:each) do
          @rfile_obj.close
        end

        it_should_behave_like "common_bytes"
      end

      describe "#chars" do
        context "default encoding" do
          before(:each) do
            @test_file_size = @file_size
            @expected_full_read_size = @file_size
            @vfile_read_test_obj = @vfile_read_obj
            @rfile_obj = VfsRealFile.new(@full_path, "r")
            @expected_returned_encoding = Encoding.default_external
          end

          after(:each) do
            @rfile_obj.close
          end

          it_should_behave_like "common_chars"
        end

        context "UTF-8 encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_chars"
        end

        context "UTF-16LE encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_16_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_16_filename, "rb:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_16_filename, "rb:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_chars"
        end

        context "Transcode UTF-8 to UTF-16LE" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = VfsRealFile.size(@utf_16_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_chars"
        end
      end

      describe "#each" do
        context "default encoding" do
          before(:each) do
            @test_file_size = @file_size
            @expected_full_read_size = @file_size
            @vfile_read_test_obj = @vfile_read_obj
            @rfile_obj = VfsRealFile.new(@full_path, "r")
            @expected_returned_encoding = Encoding.default_external
          end

          after(:each) do
            @rfile_obj.close
          end

          it_should_behave_like "common_each"
        end

        context "UTF-8 encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_each"
        end

        context "UTF-16LE encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_16_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_16_filename, "rb:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_16_filename, "rb:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_each"
        end

        context "Transcode UTF-8 to UTF-16LE" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = VfsRealFile.size(@utf_16_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_each"
        end
      end

      describe "#each_byte" do
        before(:each) do
          @rfile_obj = VfsRealFile.new(@full_path, "r")
        end

        after(:each) do
          @rfile_obj.close
        end

        it_should_behave_like "common_each_byte"
      end

      describe "#each_char" do
        context "default encoding" do
          before(:each) do
            @test_file_size = @file_size
            @expected_full_read_size = @file_size
            @vfile_read_test_obj = @vfile_read_obj
            @rfile_obj = VfsRealFile.new(@full_path, "r")
            @expected_returned_encoding = Encoding.default_external
          end

          after(:each) do
            @rfile_obj.close
          end

          it_should_behave_like "common_each_char"
        end

        context "UTF-8 encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_each_char"
        end

        context "UTF-16LE encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_16_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_16_filename, "rb:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_16_filename, "rb:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_each_char"
        end

        context "Transcode UTF-8 to UTF-16LE" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = VfsRealFile.size(@utf_16_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_each_char"
        end
      end

      describe "#each_codepoint" do
        context "default encoding" do
          before(:each) do
            @test_file_size = @file_size
            @expected_full_read_size = @file_size
            @vfile_read_test_obj = @vfile_read_obj
            @rfile_obj = VfsRealFile.new(@full_path, "r")
            @expected_returned_encoding = Encoding.default_external
          end

          after(:each) do
            @rfile_obj.close
          end

          it_should_behave_like "common_each_each_codepoint"
        end

        context "UTF-8 encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_each_each_codepoint"
        end

        context "UTF-16LE encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_16_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_16_filename, "rb:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_16_filename, "rb:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_each_each_codepoint"
        end
      end

      describe "#getbyte" do
        before(:each) do
          @rfile_obj = VfsRealFile.new(@full_path, "r")
        end

        after(:each) do
          @rfile_obj.close
        end
        
        it_should_behave_like "common_getbyte"
      end

      describe "#getc" do
        context "default encoding" do
          before(:each) do
            @test_file_size = @file_size
            @expected_full_read_size = @file_size
            @vfile_read_test_obj = @vfile_read_obj
            @rfile_obj = VfsRealFile.new(@full_path, "r")
            @expected_returned_encoding = Encoding.default_external
          end

          after(:each) do
            @rfile_obj.close
          end

          it_should_behave_like "common_getc"
        end

        context "UTF-8 encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_getc"
        end

        context "UTF-16LE encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_16_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_16_filename, "rb:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_16_filename, "rb:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_getc"
        end

        context "Transcode UTF-8 to UTF-16LE" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = VfsRealFile.size(@utf_16_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_getc"
        end
      end

      describe "#gets" do
        context "default encoding" do
          before(:each) do
            @test_file_size = @file_size
            @expected_full_read_size = @file_size
            @vfile_read_test_obj = @vfile_read_obj
            @rfile_obj = VfsRealFile.new(@full_path, "r")
            @expected_returned_encoding = Encoding.default_external
          end

          after(:each) do
            @rfile_obj.close
          end

          it_should_behave_like "common_gets"
        end

        context "UTF-8 encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_gets"
        end

        context "UTF-16LE encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_16_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_16_filename, "rb:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_16_filename, "rb:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_gets"
        end

        context "Transcode UTF-8 to UTF-16LE" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = VfsRealFile.size(@utf_16_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_gets"
        end
      end

      describe "#lines" do  # deprecated
        context "default encoding" do
          before(:each) do
            @test_file_size = @file_size
            @expected_full_read_size = @file_size
            @vfile_read_test_obj = @vfile_read_obj
            @rfile_obj = VfsRealFile.new(@full_path, "r")
            @expected_returned_encoding = Encoding.default_external
          end

          after(:each) do
            @rfile_obj.close
          end

          it_should_behave_like "common_lines"
        end

        context "UTF-8 encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_lines"
        end

        context "UTF-16LE encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_16_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_16_filename, "rb:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_16_filename, "rb:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_lines"
        end

        context "Transcode UTF-8 to UTF-16LE" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = VfsRealFile.size(@utf_16_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_lines"
        end
      end

      describe "#read" do
        context "default encoding" do
          before(:each) do
            @test_file_size = @file_size
            @expected_full_read_size = @file_size
            @vfile_read_test_obj = @vfile_read_obj
            @rfile_obj = VfsRealFile.new(@full_path, "r")
            @expected_returned_encoding = Encoding.default_external
          end

          after(:each) do
            @rfile_obj.close
          end

          it_should_behave_like "common_read"
        end

        context "UTF-8 encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_read"
        end

        context "UTF-16LE encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_16_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_16_filename, "rb:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_16_filename, "rb:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_read"
        end

        context "Transcode UTF-8 to UTF-16LE" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = VfsRealFile.size(@utf_16_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_read"
        end
      end

      describe "#readlines" do
        context "default encoding" do
          before(:each) do
            @test_file_size = @file_size
            @expected_full_read_size = @file_size
            @vfile_read_test_obj = @vfile_read_obj
            @rfile_obj = VfsRealFile.new(@full_path, "r")
            @expected_returned_encoding = Encoding.default_external
          end

          after(:each) do
            @rfile_obj.close
          end

          it_should_behave_like "common_readlines"
        end

        context "UTF-8 encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_readlines"
        end

        context "UTF-16LE encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_16_filename)
            @expected_full_read_size = @test_file_size
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_16_filename, "rb:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_16_filename, "rb:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_readlines"
        end

        context "Transcode UTF-8 to UTF-16LE" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @expected_full_read_size = VfsRealFile.size(@utf_16_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @rfile_obj = VfsRealFile.new(@utf_8_filename, "r:UTF-8:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")
          end

          after(:each) do
            @vfile_read_test_obj.close
            @rfile_obj.close
          end

          it_should_behave_like "common_readlines"
        end
      end

      describe "#ungetbyte" do
        context "default encoding" do
          before(:each) do
            @test_file_size = @file_size
            @vfile_read_test_obj = @vfile_read_obj
            @expected_returned_encoding = Encoding.default_external

            @char = "X"
            @bytes_for_char = @char.dup.force_encoding("ASCII-8BIT")
            @expected_return_char = @char
          end

          it_should_behave_like "common_ungetbyte"
        end

        context "UTF-8 encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")

            @char = "X".encode("UTF-8")
            @bytes_for_char = @char.dup.force_encoding("ASCII-8BIT")
            @expected_return_char = @char
          end

          it_should_behave_like "common_ungetbyte"
        end

        context "UTF-16LE encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_16_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_16_filename, "rb:UTF-16LE")
            @expected_returned_encoding = Encoding.find("UTF-16LE")

            @char = "X".encode("UTF-16LE")
            @bytes_for_char = @char.dup.force_encoding("ASCII-8BIT")
            @expected_return_char = @char
          end

          it_should_behave_like "common_ungetbyte"
        end
      end

      describe "#ungetc" do
        context "default encoding" do
          before(:each) do
            @test_file_size = @file_size
            @vfile_read_test_obj = @vfile_read_obj
            @expected_returned_encoding = Encoding.default_external
          end

          it_should_behave_like "common_ungetc"
        end

        context "UTF-8 encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_8_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_8_filename, "r:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")
          end

          it_should_behave_like "common_ungetc"
        end

        context "UTF-16LE encoding" do
          before(:each) do
            @test_file_size = VfsRealFile.size(@utf_16_filename)
            @vfile_read_test_obj = VirtFS::VFile.new(@utf_16_filename, "rb:UTF-16LE:UTF-8")
            @expected_returned_encoding = Encoding.find("UTF-8")
          end

          it_should_behave_like "common_ungetc"
        end
      end
    end
  end
end
