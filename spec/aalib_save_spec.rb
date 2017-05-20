require File.join(File.dirname(__FILE__), 'spec_helper')
require 'aalib'

describe "The save procedure" do
  before :each do
    @file = File.join(File.dirname(__FILE__), "scratch", "test_save")
  end

  after :each do
    # File.delete(@file) if File.exists?(@file)
  end

  it "saves a graphics context as text using the save driver" do
    format = AAlib::SaveFormat.find("text")
    data = AAlib::SaveData.new(@file, format)

    hp = AAlib::HardwareParams.new
    rp = AAlib::RenderParams.new

    context = AAlib.init(AAlib.save_driver, hp, data)
    draw_diagonal_gradient(context)
    context.render(rp)
    puts_hello_world(context)
    context.flush

    context.close

    efile = File.join(File.dirname(__FILE__), "hello_world.txt")
    expected = File.open(efile) { |f| f.read }
    result = File.open(@file) { |f| f.read }

    result.should == expected
  end
end
