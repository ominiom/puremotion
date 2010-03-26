require File.dirname(__FILE__) + '/../spec_helper.rb'

describe "media" do

  context "opening media" do

    it "should read supported formats" do
      lambda do
        PureMotion::Media.new(sample_path)
      end.should_not raise_error
    end

    it "should handle file not found" do
      lambda {
        Media('a_file_that_does_not_exist')
      }.should raise_exception(ArgumentError)
    end

    it "should handle invalid files" do
      lambda {
        Media(invalid_file)
      }.should raise_exception(PureMotion::UnsupportedFormat)
    end

  end

  context "reading media" do

    before(:all) do
      @media = Media(sample_path)
    end

    it "can check for streams" do
      @media.video?.should be_true and @media.audio?.should be_true
    end

    it "can read video resolution" do
      @media.video.resolution.should == [320, 176]
    end

    it "can detect stream types" do
      @media.video.type.should == :video and
        @media.audio.type.should == :audio
    end

    it "can read the duration" do
      @media.video.duration.should be_close(55, 3)
    end

    it "can seek reasonably accurately" do
      @media.video.seek 5
      @media.video.position.should be_close(5, 1)
    end

    after(:all) do
      @media = nil
    end

  end

  context "grabbing" do

    before(:all) do
      @media = Media(sample_path)
    end

    it "can grab a video frame" do
      @media.video.grab.should be_an_instance_of(PureMotion::Frame)
    end

    after(:all) do
      @media = nil
    end

  end

end
