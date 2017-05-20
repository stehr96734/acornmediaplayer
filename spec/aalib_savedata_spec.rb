require File.join(File.dirname(__FILE__), 'spec_helper')
require 'aalib'

describe "AAlib::SaveData.new" do
  it "Creates a new instance of SaveData" do
    file = "file.txt"
    data = AAlib::SaveData.new(file, "text")
    data.should be_an_instance_of(AAlib::SaveData)
    data.name.should == "file.txt"
  end

  it "Uses AAlib::SaveFormat.find when given a string format name" do
    file = "file.txt"
    data = AAlib::SaveData.new(file, "text")
    data.should be_an_instance_of(AAlib::SaveData)
    data.name.should == file
    data.format.should == AAlib::SaveFormat.find("text")
  end

  it "Uses AAlib::SaveFormat.find when given a regexp format name" do
    file = "file.txt"
    data = AAlib::SaveData.new(file, /text/i)
    data.should be_an_instance_of(AAlib::SaveData)
    data.name.should == file
    data.format.should == AAlib::SaveFormat.find(/text/i)
  end
end
