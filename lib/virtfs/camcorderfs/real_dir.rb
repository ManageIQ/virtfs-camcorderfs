#
# When recording calls to instance methods of File and Dir, a reference to
# the instance is passed to the method call being recorded. During the "record"
# phase, the target of the call is an instance of "real" File (or Dir).
#
# During VirtFS activation, The File constant is mapped to VirtFS::vFile,
# and a reference to the "real" File class is saved in the VfsRealFile constant.
#
# When instanitating an instance of the File class, we need to ensure we always
# use the "real" File class (as opposed to VirtFS::vFile). However, if we use
# the VfsRealFile constant to do this, it results in recording an ambiguous
# instance reference to the cassette. This is because:
#
#    VfsRealFile.class.name == File          (not VfsRealFile)
#    File.class.name        == File          (when not activated)
#    File.class.name        == VirtFS::vFile (when activated)
#
# This results in failed cassette playback during activation because it won't
# be able to find a VirtFS::vFile entry in the cassette.
#
# Using a proper subclass of the "real" File class solves this problem, because:
#    CcRealFile.class.name == CcRealFile
#
module VirtFS::CamcorderFS # rubocop:disable Style/ClassAndModuleChildren
  class RealDir < VfsRealDir
  end
end
