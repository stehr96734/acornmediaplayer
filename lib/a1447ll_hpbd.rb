require "a1447ll_hpbd/version"
require "a1447ll_hpbd/message"

module A1447llHpbd
  print "Input the someone's name who has birthday today: "
  n = gets.chomp
  s = n.upcase.split(%r{\s*})

  name = ""
  for i in 0 .. s.length-2 do
    name = name + s[i] + "."
  end
  name = ".:" + name + s[-1] + ":."

  msg = Message.new name
  puts ""
  msg.draw 
  puts "\n>> Wish you a happy birthday! <3" 		
end
