$LOAD_PATH.unshift File.expand_path('../../lib', __FILE__)
require 'virtfs'
require 'nativefs/thick'
require 'virtfs/camcorderfs'

def nativefs_class
  # VirtFS::NativeFS::Thin
  VirtFS::NativeFS::Thick
end

def reset_context
  VirtFS.context_manager.reset_all
end

def temp_name(pfx = "", sfx = "")
  Dir::Tmpname.create([pfx, sfx]) {}
end

def block_dev_file
  dev_dir = "/dev"
  return nil unless VfsRealDir.exist?(dev_dir)
  VfsRealDir.foreach(dev_dir) do |f|
    f = VfsRealFile.join(dev_dir, f)
    next unless VfsRealFile.blockdev?(f)
    return f
  end
  nil
end

def char_dev_file
  dev_dir = "/dev"
  return nil unless VfsRealDir.exist?(dev_dir)
  VfsRealDir.foreach(dev_dir) do |f|
    f = VfsRealFile.join(dev_dir, f)
    next unless VfsRealFile.chardev?(f)
    return f
  end
  nil
end

def mk_dir_tree(dir_class, prefix, breadth, depth, lvl = 0)
  return if lvl >= depth
  dir_class.mkdir(prefix)
  dir_class.chdir(prefix) do
    (1..breadth).each do |idx|
      mk_dir_tree(dir_class, "#{prefix}.#{idx}", breadth, depth, lvl + 1)
    end
  end
  nil
end

def check_dir_tree(dir_class, prefix, breadth, depth, lvl = 0)
  return if lvl >= depth
  raise "Expected directory #{prefix} does not exist" unless dir_class.exist?(prefix)
  dir_class.chdir(prefix) do
    (1..breadth).each do |idx|
      check_dir_tree(dir_class, "#{prefix}.#{idx}", breadth, depth, lvl + 1)
    end
  end
  nil
end

def rm_dir_tree(dir_class, prefix, breadth, depth, lvl = 0)
  return if lvl >= depth
  raise "Expected directory #{prefix} does not exist" unless dir_class.exist?(prefix)
  dir_class.chdir(prefix) do
    (1..breadth).each do |idx|
      rm_dir_tree(dir_class, "#{prefix}.#{idx}", breadth, depth, lvl + 1)
    end
  end
  dir_class.delete(prefix)
  nil
end

def write_test_file(file_class, path, start_marker:, end_marker:, data1:, data2:)
  size = start_marker.bytesize + end_marker.bytesize
  file_class.open(path, "w") do |file|
    file.write(start_marker)
    (0..9).each do
      file.write(data1)
      size += data1.bytesize
      file.write(data2)
      size += data2.bytesize
    end
    file.write(end_marker)
  end
  size
end

def check_test_file(file_class, path, start_marker:, end_marker:, data1:, data2:)
  file_class.open(path, "r") do |file|
    check_str(file.read(start_marker.bytesize), start_marker)
    (0..9).each do
      check_str(file.read(data1.bytesize), data1)
      check_str(file.read(data2.bytesize), data2)
    end
    check_str(file.read(end_marker.bytesize), end_marker)
  end
  nil
end

def check_str(s1, s2)
  raise "Unexpected file contents, expected: #{s1} got #{s2}" unless s1 == s2
end

def suppress_warnings
  original_verbosity = $VERBOSE
  $VERBOSE = nil
  result = yield
  $VERBOSE = original_verbosity
  result
end

def recording_file_name(path)
  path, name  = File.split(path)
  VfsRealFile.join(path, 'recordings', "#{name}.yml")
end
