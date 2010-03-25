PureMotion (0.1.0)
==================

**Homepage**:  [http://github.com/ominiom/puremotion](http://github.com/ominiom/puremotion)

OVERVIEW
--------

PureMotion is a Ruby gem for handling media files through ffmpeg


FEATURES
--------

**1. Media Information**: PureMotion uses the libav* libraries from the FFmpeg

project to read information from all FFmpeg supported media files.


**2. Transcoding**:

PureMotion provides a DSL for building and running ffmpeg transcodes with progress
reporting and logging. Consider the following code for transcoding a video to flv :

    Transcode do

        input 'sample.ogv'

        video do
            codec :flv
            resize 320, 240
            bitrate '320k'
        end

        audio do
            codec :libmp3lame
            channels 2
            bitrate '64k'
        end

        output 'converted.flv'

        log 'transcode.log'

        event :progress do |transcode, progress|
            puts "#{progress[:percent]}%"
        end

    end

**3. Thumbnails**:

The GD image library is used to resize and save in PNG format captured images from
a video stream.

    Media 'sample.mp4' do

        if video? then
            seek(5).grab.resize(320, 240).save('thumb.png')
        end

    end

BUILDING
--------

To build the PureMotion gem from source you will need to have libav* and libgd
installed.