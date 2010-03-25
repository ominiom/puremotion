req = File.expand_path(File.dirname(__FILE__)) + '/'

#require 'rubygems'

module PureMotion
  
end

require req + 'puremotion_native'
require req + 'events/event'
require req + 'events/generator'

Object.extend(PureMotion::Events::Generator)

require req + 'threading'
require req + 'media'
require req + 'codecs'
require req + 'transcode/transcode'
require req + 'transcode/recipe'
require req + 'tools/ffmpeg'
