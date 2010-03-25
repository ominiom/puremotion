require 'puremotion'

PureMotion::Media.new('/media/Storage/DVD/lemans.mp4').video.seek(10).grab.resize(320, 240).save('/home/iain/test.png')