Transcode '../spec/samples/sample.ogv' do

  event :failure do |reason, message|
    puts "Failure - #{message}"
  end

  event :complete do |output|
    puts "Success! Output is #{output.video.duration}"
  end

  overwrite!

  video do
    codec :flv
    bitrate '200k'
    resolution 320, 176
  end

  audio do
    codec :libmp3lame
    bitrate '96k'
  end

  log 'failure_handling.log'

  output '/totally/invalid/path/on/normal/systems.flv'

end