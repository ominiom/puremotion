req = File.expand_path(File.dirname(__FILE__)) + '/'

#require 'rubygems'

module PureMotion
  
end

require req + 'puremotion_native'
require req + 'events/event'
require req + 'events/generator'

Object.extend(PureMotion::Events::Generator)

require req + 'preset/preset'

require req + 'preset/general'
require req + 'preset/file'
require req + 'preset/metadata'
require req + 'preset/video/video'
require req + 'preset/video/crop'
require req + 'preset/video/pad'
require req + 'preset/audio/audio'


require req + 'threading'
require req + 'media'
require req + 'transcode/transcode'
require req + 'tools/ffmpeg'
