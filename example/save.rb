require 'aalib'

hp = AAlib::HardwareParams.new
rp = AAlib::RenderParams.new

AAlib.parseoptions(hp, rp) or abort AAlib.help

file = "aalib-save-demo.txt"
savedata = AAlib::SaveData.new(file, "text", AAlib::SaveFormat::USE_PAGES)
aa = AAlib.init(AAlib.save_driver, hp, savedata)

aa or abort "failed to initialize AA-lib"

begin
  # Fill screen with diagonal gradient
  width = aa.imgwidth
  height = aa.imgheight
  height.times do |y|
    width.times do |x|
      aa.putpixel(x, y, 127*(x.to_f/width) + 127*(y.to_f/height))
    end
  end

  rp.randomval = 25
  aa.render(rp)

  msg = '  AA-lib: the ascii-art library  '
  blank = ' ' * msg.size
  attr = AAlib::Attr::BOLD
  col = (aa.scrwidth - msg.size)/2
  row = aa.scrheight/2
  aa.puts(col, row - 1, attr, blank)
  aa.puts(col, row, attr, msg)
  aa.puts(col, row + 1, attr, blank)

  if File.exists?(file)
    print "File exists: \"#{file}\"  Will not overwrite.\n"
  else
    print "Saving \"#{file}\" ... "
    aa.flush  # Saves file to disk
    print "ok.\n"
  end
ensure
  aa.close
end
