require File.join(File.dirname(__FILE__), 'spec_helper')
require 'aalib'

describe "AAlib::SaveFormat.find" do
  it "finds formats when given the full formatname" do
    format = AAlib::SaveFormat.find("Text file")
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "Text file"
    format.extension.should == ".txt"

    format = AAlib::SaveFormat.find("Pure html")
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "Pure html"
    format.extension.should == ".html"

    ## NOTE: the "seqences" typo are hard coded into AA-lib v 1.4
    format = AAlib::SaveFormat.find("ANSI escape seqences")
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "ANSI escape seqences"
    format.extension.should == ".ansi"
  end

  it "finds formats when given the partial formatname" do
    format = AAlib::SaveFormat.find("Text")
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "Text file"
    format.extension.should == ".txt"

    format = AAlib::SaveFormat.find("html")
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "Pure html"
    format.extension.should == ".html"

    format = AAlib::SaveFormat.find("ANSI")
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "ANSI escape seqences"
    format.extension.should == ".ansi"
  end

  it "finds formats ignoring case" do
    format = AAlib::SaveFormat.find("tEXT")
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "Text file"
    format.extension.should == ".txt"

    format = AAlib::SaveFormat.find("HTML")
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "Pure html"
    format.extension.should == ".html"

    format = AAlib::SaveFormat.find("ansi")
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "ANSI escape seqences"
    format.extension.should == ".ansi"
  end

  it "finds formats when given a Regexp" do
    format = AAlib::SaveFormat.find(/text/i)
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "Text file"
    format.extension.should == ".txt"

    format = AAlib::SaveFormat.find(/HP.*big/)
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "HP laser jet - A4 big font"
    format.extension.should == ".hp"

    format = AAlib::SaveFormat.find(/IRC.*II/)
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "For catting to an IRC channel II"
    format.extension.should == ".irc"
  end
end

describe "AAlib::SaveFormat.formatname" do
  it "returns the formatname" do
    format = AAlib::SaveFormat.find("text")
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.formatname.should == "Text file"
  end
end

describe "AAlib::SaveFormat.extension" do
  it "returns the file extension including the dot" do
    format = AAlib::SaveFormat.find("text")
    format.should be_an_instance_of(AAlib::SaveFormat)
    format.extension.should == ".txt"
  end
end
