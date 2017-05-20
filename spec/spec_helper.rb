$LOAD_PATH.unshift File.join(File.dirname(__FILE__), '..', 'lib')
require 'aalib'

def draw_diagonal_gradient(context)
  width = context.imgwidth
  height = context.imgheight
  height.times do |y|
    width.times do |x|
      context.putpixel(x, y, 127*(x.to_f/width) + 127*(y.to_f/height))
    end
  end
end

def puts_hello_world(context)
  msg = '  AA-lib: the ascii-art library  '
  blank = ' ' * msg.size
  attr = AAlib::Attr::BOLD
  col = (context.scrwidth - msg.size)/2
  row = context.scrheight/2
  context.puts(col, row - 1, attr, blank)
  context.puts(col, row, attr, msg)
  context.puts(col, row + 1, attr, blank)
end
