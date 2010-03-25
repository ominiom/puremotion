require File.dirname(__FILE__) + '/../spec_helper.rb'

describe PureMotion::Preset do

  it "should support all possible inputs" do
    begin
    PureMotion::Preset.build do

      input sample_path

      overwrite!

      seek 2
      duration 10

      file do

        size_limit 10_000_000

      end

      metadata do

        title "Test"
        author "Me"
        copyright "None whatsoever"
        album "Test"
        track 2
        comment "Brilliant"
        year 1989

      end

      video do

        disable

        buffer '200'

        bitrate '300k'
        bitrate 300

        same_quality

        frames 100

        framerate 25
        fps 25

        resolution 320, 240
        resolution [320, 240]
        resolution '320x240'
        resolution :vga

        crop do
          top 10
          bottom 20
          left 30
          right 40
        end

        pad do
          top 40
          bottom 30
          left 20
          right 10

          color "333333"
        end

      end

      audio do

        disable

        channels 2
        sampling 44100
        frames 100

        language :eng

      end

      output "output.mp4"

    end
    end.should_not raise_error
  end

end