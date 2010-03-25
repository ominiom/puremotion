require File.dirname(__FILE__) + '/../spec_helper.rb'

describe PureMotion::Media do

  it "should read supported formats" do
    lambda do
      PureMotion::Media.new(sample_path)
    end.should_not raise_error
  end



end
