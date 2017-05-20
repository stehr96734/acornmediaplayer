require File.join(File.dirname(__FILE__), 'spec_helper')
require 'aalib'

describe "AAlib.autoinit" do
  # We can't check this so much because it might initialize Curses on our terminal
  #
  it "raises TypeError with wrong hardware_params" do
    clo = lambda { AAlib.autoinit(Object.new) }
    clo.should raise_error(TypeError)
  end
end

describe "AAlib.init" do
  before :each do
    @hp = AAlib::HardwareParams.new
  end

  # AAlib.init checks its arguments in violation of duck typing, but incorrect
  # arguments can lead to segmentation faults if AAlib calls the C-library
  # functions with incorrect arguments.

  it "raises TypeError with wrong driver" do
    clo = lambda { AAlib.init(Object.new) }
    clo.should raise_error(TypeError)
  end

  it "raises TypeError with wrong hardware_params" do
    clo = lambda { AAlib.init(AAlib.memory_driver, Object.new) }
    clo.should raise_error(TypeError)
  end

  it "returns an AAlib::Context with memory driver" do
    AAlib.init(AAlib.memory_driver, @hp).should be_an_instance_of(AAlib::Context)
  end

  it "returns an AAlib::Context with memory driver and no hardware_params" do
    AAlib.init(AAlib.memory_driver).should be_an_instance_of(AAlib::Context)
  end

  it "returns an AAlib::Context when called with save driver" do
    opts = AAlib::SaveData.new("test.txt", "text")
    context = AAlib.init(AAlib.save_driver, @hp, opts)
    context.should be_an_instance_of(AAlib::Context)
  end

  it "raises ArgumentError when called with save driver and no driver_opts" do
    clo = lambda { AAlib.init(AAlib.save_driver, @hp, nil) }
    clo.should raise_error(ArgumentError)
  end

  it "raises TypeError when called with save driver and wrong driver_opts" do
    opts = AAlib::SaveFormat.find("text")
    clo = lambda { AAlib.init(AAlib.save_driver, @hp, opts) }
    clo.should raise_error(TypeError)
  end
end

# describe "AAlib.color_from_rgb" do
#   it "converts an RGB color to greyscale" do
#     AAlib.color_from_rgb(0, 0, 0).should == 0
#     AAlib.color_from_rgb(255, 255, 255).should == 255
#     AAlib.color_from_rgb(255, 0, 0).should == 29
#     AAlib.color_from_rgb(0, 255, 0).should == 58
#     AAlib.color_from_rgb(0, 0, 255).should == 10
#     AAlib.color_from_rgb(47, 57, 98).should == 22
#   end
# 
#   it "behaves stupidly when args are larger than 255" do
#     AAlib.color_from_rgb(256, 0, 0).should == 30
#   end
# end

describe "AAlib.help" do
  it "returns a large help string" do
    AAlib.help.should be_an_instance_of(String)
  end
end

describe "AAlib.formats" do
  it "returns an array of formats" do
    AAlib.formats.should be_an_instance_of(Array)
  end

  it "returns an array of AAlib::SaveFormat objects" do
    AAlib.formats.each do |driver|
      driver.should be_an_instance_of(AAlib::SaveFormat)
    end
  end
end

describe "AAlib.drivers" do
  it "returns an array of drivers" do
    AAlib.drivers.should be_an_instance_of(Array)
  end

  it "returns an array of AAlib::Driver objects" do
    AAlib.drivers.each do |driver|
      driver.should be_an_instance_of(AAlib::Driver)
    end
  end
end

describe "AAlib.save_driver" do
  it "returns the driver to use for saving to disk" do
    driver = AAlib.save_driver
    driver.should be_an_instance_of(AAlib::Driver)
    driver.shortname.should == 'save'
    driver.name.should == 'Special driver for saving to files'
  end
end

describe "AAlib.memory_driver" do
  it "returns the driver to use for an in-memory context" do
    driver = AAlib.memory_driver
    driver.should be_an_instance_of(AAlib::Driver)
    driver.shortname.should == 'mem'
    # FIXME: may depend on AA-lib version?
    driver.name.should == 'Dummy memory driver 1.0'
  end
end

describe "AAlib.parseoptions" do
  before :each do
    @hp = AAlib::HardwareParams.new
    @rp = AAlib::RenderParams.new
  end

  it "parses commandline options, setting values in RenderParams" do
    argv = %w{-gamma 2.0 -contrast 5 -bright 100}
    AAlib.parseoptions(@hp, @rp, argv).should be_true
    @rp.gamma.should be_close(2.0, 0.01)
    @rp.contrast.should == 5
    @rp.bright.should == 100
  end

  it "parses commandline options, setting values in HardwareParams" do
    argv = %w{-width 101 -height 57}
    AAlib.parseoptions(@hp, @rp, argv).should be_true
    @hp.width.should == 101
    @hp.height.should == 57
  end

  it "leaves untouched other options" do
    argv = %w{--verbose -gamma 2.0 -contrast 5 -bright 100 -other-option 70}
    AAlib.parseoptions(@hp, @rp, argv).should be_true
    argv.should == %w{--verbose -other-option 70}
  end

  it "uses ARGV by default" do
    ARGV.replace %w{--verbose -gamma 2.0 -contrast 5 -bright 100 -other-option 70}
    AAlib.parseoptions(@hp, @rp).should be_true
    ARGV.should == %w{--verbose -other-option 70}

    @rp.gamma.should be_close(2.0, 0.01)
    @rp.contrast.should == 5
    @rp.bright.should == 100
  end

  it "raises TypeError with wrong hardware_params" do
    clo = lambda { AAlib.parseoptions(Object.new, @rp) }
    clo.should raise_error(TypeError)
  end

  it "raises TypeError with wrong hardware_params" do
    clo = lambda { AAlib.parseoptions(@hp, Object.new) }
    clo.should raise_error(TypeError)
  end
end
