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

  end

  context "reading media" do

    it "can check for streams" do
      media = Media(sample_path)
      media.video?.should be_true and media.audio?.should be_true
    end

  end

end
