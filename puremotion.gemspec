# Generated by jeweler
# DO NOT EDIT THIS FILE DIRECTLY
# Instead, edit Jeweler::Tasks in Rakefile, and run the gemspec command
# -*- encoding: utf-8 -*-

Gem::Specification.new do |s|
  s.name = %q{puremotion}
  s.version = "0.0.1"

  s.required_rubygems_version = Gem::Requirement.new(">= 0") if s.respond_to? :required_rubygems_version=
  s.authors = ["Ominiom"]
  s.date = %q{2010-03-24}
  s.description = %q{A Ruby wrapper for FFmpeg}
  s.email = %q{iain.iw.wilson@googlemail.com}
  s.extensions = ["ext/puremotion/extconf.rb"]
  s.extra_rdoc_files = [
    "LICENSE",
     "README.rdoc"
  ]
  s.files = [
    "ext/puremotion/audio.c",
     "ext/puremotion/extconf.rb",
     "ext/puremotion/frame.c",
     "ext/puremotion/media.c",
     "ext/puremotion/puremotion.c",
     "ext/puremotion/puremotion.h",
     "ext/puremotion/stream.c",
     "ext/puremotion/stream_collection.c",
     "ext/puremotion/test.rb",
     "ext/puremotion/utils.c",
     "ext/puremotion/utils.h",
     "ext/puremotion/video.c",
     "lib/codecs.rb",
     "lib/events/event.rb",
     "lib/events/generator.rb",
     "lib/media.rb",
     "lib/puremotion.rb",
     "lib/recipes/ipod.yml",
     "lib/threading.rb",
     "lib/tools/ffmpeg.rb",
     "lib/transcode/recipe.rb",
     "lib/transcode/transcode.rb"
  ]
  s.homepage = %q{http://github.com/ominiom/puremotion}
  s.rdoc_options = ["--charset=UTF-8"]
  s.require_paths = ["lib"]
  s.rubygems_version = %q{1.3.5}
  s.summary = %q{PureMotion}

  if s.respond_to? :specification_version then
    current_version = Gem::Specification::CURRENT_SPECIFICATION_VERSION
    s.specification_version = 3

    if Gem::Version.new(Gem::RubyGemsVersion) >= Gem::Version.new('1.2.0') then
    else
    end
  else
  end
end
