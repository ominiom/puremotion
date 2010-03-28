# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{puremotion}
  s.version = "0.1.0"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ominiom"]
  s.date = %q{2010-03-27}
  s.description = %q{A Ruby wrapper for FFmpeg}
  s.email = %q{iain@ominiom.com}
  s.extensions = ["ext/puremotion/extconf.rb"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.markdown"
  ]
  s.files = [
    ".yardopts",
     "LICENSE",
     "README.markdown",
     "Rakefile",
     "ext/puremotion/audio.c",
     "ext/puremotion/extconf.rb",
     "ext/puremotion/frame.c",
     "ext/puremotion/media.c",
     "ext/puremotion/puremotion.c",
     "ext/puremotion/puremotion.h",
     "ext/puremotion/stream.c",
     "ext/puremotion/stream_collection.c",
     "ext/puremotion/utils.c",
     "ext/puremotion/utils.h",
     "ext/puremotion/video.c",
     "lib/events/event.rb",
     "lib/events/generator.rb",
     "lib/media.rb",
     "lib/preset/audio/audio.rb",
     "lib/preset/file.rb",
     "lib/preset/general.rb",
     "lib/preset/metadata.rb",
     "lib/preset/preset.rb",
     "lib/preset/video/crop.rb",
     "lib/preset/video/pad.rb",
     "lib/preset/video/video.rb",
     "lib/puremotion.rb",
     "lib/puremotion_native.so",
     "lib/threading.rb",
     "lib/tools/ffmpeg.rb",
     "lib/transcode/transcode.rb"
  ]
  s.homepage = %q{http://github.com/ominiom/puremotion}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.6}
  s.summary = %q{PureMotion}
  s.test_files = [
    "spec/units/media_spec.rb",
     "spec/units/preset_spec.rb",
     "spec/spec_helper.rb",
     "examples/progress_reporting.rb",
     "examples/test.rb",
     "examples/simple.rb"
  ]

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end

