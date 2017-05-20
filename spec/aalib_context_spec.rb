require File.join(File.dirname(__FILE__), 'spec_helper')

Spec::Runner.configure do |config|
  config.before :each do
    @aa = AAlib.init(AAlib.memory_driver)
  end

  config.after :each do
    @aa.close if @aa
  end
end

describe "AAlib::Context#mulx" do
  it "returns the ratio of image and screen widths" do
    @aa.mulx.should == @aa.imgwidth / @aa.scrwidth
  end
end

describe "AAlib::Context#muly" do
  it "returns the ratio of image and screen heights" do
    @aa.mulx.should == @aa.imgwidth / @aa.scrwidth
  end
end

describe "AAlib::Context#imgwidth" do
  it "returns the width of the image buffer" do
    hp = AAlib::HardwareParams.new
    hp.width = 100
      aa = AAlib.init(AAlib.memory_driver, hp)
    begin
      aa.imgwidth.should == 100 * aa.mulx
    ensure
      aa.close
    end
  end
end

describe "AAlib::Context#imgheight" do
  it "returns the width of the image buffer" do
    hp = AAlib::HardwareParams.new
    hp.height = 100
    aa = AAlib.init(AAlib.memory_driver, hp)
    begin
      aa.imgheight.should == 100 * aa.muly
    ensure
      aa.close
    end
  end
end

describe "AAlib::Context#render" do
  it "raises TypeError with wrong render_params" do
    lambda { @aa.render(Object.new) }.should raise_error(TypeError)
  end
end

describe "AAlib::Context#putpixel" do
  it "puts a pixel to the image buffer" do
    50.times do
      color = rand(256)
      x = rand(@aa.imgwidth)
      y = rand(@aa.imgheight)
      @aa.putpixel(x, y, color)
      @aa.image[y*@aa.imgwidth + x].should == color
    end
  end
end

describe "AAlib::Context#copy_image_from" do
  before :each do
    @aa1 = AAlib.init(AAlib.memory_driver)
    @aa2 = AAlib.init(AAlib.memory_driver)
  end

  after :each do
    @aa1.close
    @aa2.close
  end

  it "copies the image buffer from another AAlib::Context" do
    pixels = Hash.new
    100.times do
      x = rand(@aa2.imgwidth)
      y = rand(@aa2.imgheight)
      color = rand(256)
      @aa2.putpixel(x, y, color)
      pixels[[x,y]] = color
    end

    @aa1.copy_image_from(@aa2)
    pixels.each do |xy, color|
      @aa1.image[@aa1.imgwidth*xy[1] + xy[0]].should == color
    end
  end
end
