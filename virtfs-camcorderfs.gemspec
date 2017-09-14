# coding: utf-8
lib = File.expand_path('../lib', __FILE__)
$LOAD_PATH.unshift(lib) unless $LOAD_PATH.include?(lib)
require 'virtfs/camcorderfs/version'

Gem::Specification.new do |spec|
  spec.name          = "virtfs-camcorderfs"
  spec.version       = VirtFS::CamcorderFS::VERSION
  spec.authors       = ["Richard Oliveri"]
  spec.email         = ["roliveri@redhat.com"]

  spec.summary       = "A Camcorder based filesystem module for VirtFS"
  spec.description   = %q{
    Records all filesystem interactions that are performed under the mount point
    of the CamcorderFS. The recordings can then be replayed in the same manner
    as VCR or Camcorder recordings.
  }
  spec.homepage      = ""
  spec.license       = "MIT"

  spec.files         = `git ls-files -z`.split("\x0").reject { |f| f.match(%r{^(test|spec|features)/}) }
  spec.bindir        = "exe"
  spec.executables   = spec.files.grep(%r{^exe/}) { |f| File.basename(f) }
  spec.require_paths = ["lib"]

  spec.add_runtime_dependency "virtfs"
  spec.add_runtime_dependency "camcorder"

  spec.add_development_dependency "bundler", "~> 1.10"
  spec.add_development_dependency "rake", "~> 10.0"
  spec.add_development_dependency "rspec"
end
