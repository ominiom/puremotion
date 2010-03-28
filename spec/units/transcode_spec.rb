require File.dirname(__FILE__) + '/../spec_helper.rb'

describe PureMotion::Transcode::Transcode do

  it "should detect missing files" do
    lambda {

      Transcode '/gibberish/path' do

      end

    }.should raise_error ArgumentError
  end

end