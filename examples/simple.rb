Transcode do

  input '../spec/samples/sample.ogv'

  overwrite!

  video do
    codec :flv
    resolution 320, 240
    bitrate '240k'
  end

  audio do
    codec :libmp3lame
    bitrate '64k'
  end

  output 'test.flv'

  log 'simple.log'

end