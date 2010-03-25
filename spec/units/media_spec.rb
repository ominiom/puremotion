require File.dirname(__FILE__) + '/../spec_helper.rb'

describe PureMotion::Media do

  before(:each) do
    @input = "sample.wmv"
  end

  it "should read supported formats" do
    lambda do
      PureMotion::Media.new(@input)
    end.should_not raise_error
  end



end
