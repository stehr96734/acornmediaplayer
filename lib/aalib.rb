# AAlib-Ruby brings graphics to the text terminal.  AAlib-Ruby provides both a
# graphics context rendered as ascii-art and keyboard and mouse input.
# AAlib-Ruby supports a number of text-only display drivers such as Curses,
# SLang, and X11.
#
# This is a DL based wrapper around the AA-lib C library.  C struct alignment
# issues may cause problems on certain platforms when accessing variables of
# some objects.
#
# Author::  Patrick Mahoney (mailto:pat@polycrystal.org)
# Copyright:: Copyright (c) 2007 Patrick Mahoney
# License:: Distributes under the same terms as Ruby
#
# See README for a usage overview.

require 'dl'

module DL #:nodoc:all
  class << self
    # Attempts to open each library in the Array libs with DL.dlopen. Returns
    # the first that is successfully opened.  This is a convenience function
    # for compatibility with different platforms where the dynamic library may
    # be named differently.
    def tryopen(libs)
      dllib = nil
      errs = Array.new

      libs.each do |lib|
        begin
          dllib = DL.dlopen lib
        rescue => err
          errs << err
        end
        break if dllib
      end

      unless dllib
        msg = errs.collect{ |e| e.message }.join('; ')
        raise RuntimeError.new("failed to open library: (#{msg})")
      else
        dllib
      end
    end
  end

  class PtrData
    def string?
      p self.data_type
      data_type[1] == 'S'
    end
  end
end

# This module provides initialization methods and other miscellaneous methods.

module AAlib
  class Error < RuntimeError; end

  module Foreign #:nodoc:all
    class << self

      # Defines a method named sym that calls the given function from DL:Handle
      # lib using the DL function signature sig.  This method is modeled after
      # a similar method in Rubinius' FFI.
      #
      def attach_function(lib, func, sym, sig)
        self.class.send(:define_method, sym) do |*args|
          # print "calling #{func}("
          # if args
          #   argstr = args.collect do |a|
          #     if a.kind_of? Array
          #       a.inspect
          #     elsif a.kind_of? DL::PtrData
          #       a.class
          #     else
          #       "'#{a}'"
          #     end
          #   end
          #   print argstr.join(', ')
          # end
          # print ")\n"
          lib[func, sig].call(*args)
        end
      end

      # Defines a method named _sym_ that returns the global variable _global_
      # from DL:Handle lib.
      #
      def attach_global(lib, global, sym)
        self.class.send(:define_method, sym) do
          lib[global]
        end
      end
    end

    LIB = DL.tryopen ['libaa.so.1', 'libaa.so', 'libaa']

    # Global vars
    attach_global LIB, 'aa_help', :help
    attach_global LIB, 'aa_defparams', :defparams
    attach_global LIB, 'aa_defrenderparams', :defrenderparams

    attach_global LIB, 'aa_drivers', :drivers
    attach_global LIB, 'save_d', :save_driver
    attach_global LIB, 'mem_d', :mem_driver

    attach_global LIB, 'aa_formats', :formats

    # Functions
    attach_function LIB, 'aa_parseoptions', :parseoptions, 'IPPPa'
    attach_function LIB, 'aa_init', :init, 'PPPP'
    attach_function LIB, 'aa_close', :close, '0P'

    attach_function LIB, 'aa_autoinit', :autoinit, 'PP'
    attach_function LIB, 'aa_autoinitkbd', :autoinitkbd, 'IPI'
    attach_function LIB, 'aa_autoinitmouse', :autoinitmouse, 'IPI'

    attach_function LIB, 'aa_image', :image, 'PP'
    attach_function LIB, 'aa_text', :text, 'PP'
    attach_function LIB, 'aa_attrs', :attrs, 'PP'
    attach_function LIB, 'aa_currentfont', :font, 'PP'
    
    attach_function LIB, 'aa_scrwidth', :scrwidth, 'IP'
    attach_function LIB, 'aa_scrheight', :scrheight, 'IP'
    attach_function LIB, 'aa_imgwidth', :imgwidth, 'IP'
    attach_function LIB, 'aa_imgheight', :imgheight, 'IP'
    attach_function LIB, 'aa_mmwidth', :mmwidth, 'IP'
    attach_function LIB, 'aa_mmheight', :mmheight, 'IP'

    attach_function LIB, 'aa_fastrender', :fastrender, '0PIIII'
    attach_function LIB, 'aa_render', :render, '0PPIIII'
    attach_function LIB, 'aa_flush', :flush, '0P'

    attach_function LIB, 'aa_putpixel', :putpixel, '0PIII'
    attach_function LIB, 'aa_puts', :puts, '0PIIIS'

    attach_function LIB, 'aa_getevent', :getevent, 'IPI'
    attach_function LIB, 'aa_getkey', :getkey, 'IPI'
    attach_function LIB, 'aa_resize', :resize, 'IP'
    attach_function LIB, 'aa_resizehandler', :resize_handler, '0PP'

    attach_function LIB, 'aa_gotoxy', :gotoxy, '0PII'
    attach_function LIB, 'aa_hidecursor', :hidecursor, '0P'
    attach_function LIB, 'aa_showcursor', :showcursor, '0P'
    attach_function LIB, 'aa_getmouse', :getmouse, '0PPPP'
    attach_function LIB, 'aa_hidemouse', :hidemouse, '0P'
  end

  # AAlib key code

  module Key
    RESIZE = 258
    MOUSE = 259
    UP = 300
    DOWN = 301
    LEFT = 302
    RIGHT = 303
    BACKSPACE = 304
    UNKNOWN = 400
    RELEASE = 65536
  end

  # AAlib mouse events

  module Mouse
    BUTTON1 = 1
    BUTTON2 = 2
    BUTTON3 = 4
    MOVEMASK = 1
    PRESSMASK = 2
    PRESSEDMOVEMASK = 4
    ALLMASK = 7
    HIDECURSOR = 8
  end

  SENDRELEASE = 1
  KBDALLMASK = 1

  # Attribute masks

  module AttrMask
    NORMAL = 1
    DIM = 2
    BOLD = 4
    BOLDFONT = 8
    REVERSE = 16
    ALL = 128
    EIGHT = 256
    EXTENDED = (ALL|EIGHT)
  end

  # Text attributes for AAlib#puts and other text methods.

  module Attr
    NORMAL = 0
    DIM = 1
    BOLD = 2
    BOLDFONT = 3
    REVERSE = 4
    SPECIAL = 5
  end

  # Dithering modes for AAlib#render.

  module Dither
    NONE = 0
    ERRORDISTRIB = 1
    FLOYD_S = 2
    DITHERTYPES = 3 # Number of supported types
  end

  module ArgumentChecks  #:nodoc:all
    class << self
      def included(receiver)
        receiver.extend ClassMethods
      end
    end

    module ClassMethods
      def check_type(arg, argname, expected)
        if not arg.kind_of?(expected)
          msg = "#{argname}: wrong argument type #{arg.class} "
          msg += "(expected #{expected})"
          raise TypeError.new(msg)
        end
      end

      def check_hardware_params(hp)
        check_type(hp, "hardware_params", AAlib::HardwareParams)
      end

      def check_render_params(rp)
        check_type(rp, "render_params", AAlib::RenderParams)
      end
    end
  end

  include ArgumentChecks  #:nodoc:

  class << self

    # Returns the AAlib command line options help text.  Note that the text is
    # formatted to 74 columns.

    def help
      help = Foreign.help
      help.struct!('S', :text)
      help[:text].to_s
    end

    # Parse commandline options from the given Array of Strings, _argv_,
    # parsing AAlib options and removing them from the array.  Fills in
    # _hardware_params_ and _render_params_ with appropriate values based on
    # the commandline arguments.  It is expected that these parameters be used
    # to initialize AAlib and render graphics.
    #
    # Note that this function replaces the strings in the given argv with new,
    # duplicate strings.

    def parseoptions(hardware_params, render_params, argv=ARGV)
      check_hardware_params(hardware_params)
      check_render_params(render_params)

      cargv = [$0, argv].flatten  # C argv includes $0

      cargc = DL.malloc(DL.sizeof('I'))
      cargc.struct!('I', :num)
      cargc[:num] = cargv.size

      r,rs = Foreign.parseoptions(hardware_params, render_params,
                                  cargc, cargv)

      if r == 1  # success
        rs[2].struct!('I', :num)
        len = rs[2][:num]

        newargv = rs[3].to_a('S', len)
        newargv.shift  # remove $0 that we added previously
        argv.replace newargv
        true
      else
        false
      end
    end

    # Initializes AA-lib.  Attempts to find an available output driver
    # supporting the optionally specified _hardware_params_.  First attempts to
    # initialize the recommended drivers and then in order drivers available in
    # the AAlib.drivers array.
    #
    # Returns an AAlib::Context on success or nil on failure.

    def autoinit(hardware_params=HardwareParams::DEFAULT)
      check_hardware_params(hardware_params)

      ptr, garbage = Foreign.autoinit(hardware_params)
      Context.new(ptr)
    end

    # Initializes AA-lib using the specified _driver_ from AAlib.drivers and
    # optionally specified _hardware_params_.  Use _driver_opts_ to pass extra
    # options to a hardware driver.  For example, pass an instance of
    # AAlib::SaveData when using AAlib.save_driver. Note that _driver_opts_ is
    # a required argument when using the save driver.
    #
    # Returns an AAlib::Context on success or nil on failure.

    def init(driver, hardware_params=HardwareParams::DEFAULT, driver_opts=nil)
      check_type(driver, "driver", AAlib::Driver)

      if driver == AAlib.save_driver
        if driver_opts == nil
          msg = "AAlib::SaveData required as third argument when using save driver"
          raise ArgumentError.new(msg)
        else
          check_type(driver_opts, "driver_opts", AAlib::SaveData)
        end
      end

      check_hardware_params(hardware_params)

      ptr, garbage = Foreign.init(driver, hardware_params, driver_opts)
      Context.new(ptr)
    end

    # Returns array of supported display drivers.  See AAlib::Driver.

    def drivers
      array_from_null_terminated_c(Foreign.drivers, Driver)
    end

    # Returns array of supported save formats.  See AAlib::SaveFormat.

    def formats
      array_from_null_terminated_c(Foreign.formats, SaveFormat)
    end

    # Returns an AAlib::Driver for an in-memory context for custom ascii-art
    # output. should be passed to AAlib.init.

    def memory_driver
      AAlib::Driver.new(Foreign.mem_driver)
    end

    # Returns an AAlib::Driver for saving a AAlib::Context to disk in various
    # formats; should be passed to AAlib.init.

    def save_driver
      AAlib::Driver.new(Foreign.save_driver)
    end

    # Returns a grey value (0-255) approximating the brightness of the given
    # RGB value where _r_, _g_, and _b_ range from 0-255.

    #def color_from_rgb(r, g, b)
    #  (r*30 + g*59 +b*11) >> 8
    #end

    # Converts a NULL terminated C pointer array into a Ruby array of objects
    # made by talling target_class.new() on each DL::PtrData in the C array.

    def array_from_null_terminated_c(ptr, target_class)  #:nodoc:
      targets = Array.new
      loop do
        ptr.struct!('P', :target)
        target = ptr[:target]
        break unless target
        targets << target_class.new(target)
        ptr += DL.sizeof('P')
      end
      targets
    end
  end

  # Adds initialization and some other features to DL::PtrData.  On
  # initialization, PtrData is defined (struct!) using the given TYPE and NAMES
  # that may be used alone or
  # via StructAccessors.

  class CPtr < DL::PtrData
    include ArgumentChecks  #:nodoc:
    # TYPE = ''  # subclasses should define this

    class << self

      # Allocates memory based on the class constant TYPE specified in DL style
      # returning an uninitialized CPtr object.

      def new_ptr
        malloc(DL.sizeof(const_get(:TYPE)))
      end

      private
      
      def struct_field(sym, writable=false)
        define_method(sym) do
          self[sym]
        end

        if writable
          define_method((sym.to_s + '=').to_sym) do |val|
            self[sym] = val
          end
        end
      end

      def struct_reader(*syms)
        syms.each { |sym| struct_field(sym) }
      end

      def struct_accessor(*syms)
        syms.each { |sym| struct_field(sym, true) }
      end
    end

    # Initializes a CPtr based on the TYPE and NAMES definitions of the current
    # class.  If a subclass of CPtr defines the NAMES constant, then _with_ptr_
    # will be initialized using DL::PtrData#struct! with the defined TYPE and
    # NAMES so that members may be accessed using CPtr#[] with string or symbol
    # names.
    #
    # If no _with_ptr_ is given, a new pointer is allocated using the
    # CPtr.new_ptr or the new_ptr method of a subclass of CPtr.

    def initialize(with_ptr=nil)
      with_ptr ||= self.class.new_ptr
      super(with_ptr)
      if self.class.const_defined? :NAMES
        struct! self.class.const_get(:TYPE), *(self.class.const_get(:NAMES))
      end
    end

    # When called with integral arguments, returns data from the pointer
    # similar to String#[].  If passed one _int_, returns the integer value of
    # the character stored at that index.  If passed two _ints_, returns the
    # substring of length _len_ starting at position _key_.
    #
    # When called with a Symbol or String, returns a DL::PtrData of the denoted
    # member.  If a subclass defines TYPE and NAMES and the type of the member
    # is String, it will be returned as a String using DL::PtrData#to_s.

    def [](key, len=0)
      if key.kind_of? Integer
        if len == 0
          # We'd like this to behave more like String#[] where a single numeric
          # index gets you the char type integer at the given index.  Ruby
          # 1.9's DL possible fixes the need for this.
          super(key, 1)[0]
        else
          super(key, len)
        end
      elsif (names = self.class.const_get(:NAMES)) &&
             (type = self.class.const_get(:TYPE)) &&
             (type[(names.index(key)), 1] == 'S')
             super(key).to_s
      else
        super(key)
      end
    end

    # Identical to DL::PtrData#[]= except that it raises an error on frozen
    # objects.
    #
    # With two _ints_, _key_ and _val_, sets the value at _key_ to _val_.  With
    # one _int_ and one _str_ sets the characters begining at _key_ to those of
    # _str_.  With two _ints_, _key_ and _num_, and one _str_, copies at most
    # _num_ characters of _str_, extending with zeroes if _len_ is greater than
    # the length of _str_.
    #
    # When called with a Symbol or String, sets the value of the denoted
    # member.  A subclass must have defined TYPE and NAMES so that DL::PtrData
    # knows how to handle each member.
 
    def []=(key, num, val=nil)
      if frozen?
        @assignment_will_raise_error = true
      elsif val
        super(key, num, val)
      else
        val = num
        super(key, val)
      end
    end

    def inspect  #:nodoc:
      if self.class.const_defined? :NAMES
        values = Array.new
        names = self.class.const_get(:NAMES)
        names.each_with_index do |name, i|
          label = name.to_s
          value = self[name]
          values << "%s=%s" % [label, value.inspect]
        end

        "#<%s:%x %s>" % [self.class, ~object_id, values.join(' ')]
      else
        super
      end
    end
  end

  class RenderParams < CPtr
    TYPE = 'IIFIII'  #:nodoc:
    NAMES = [:bright, :contrast, :gamma, :dither, :inversion, :randomval]  #:nodoc:

    struct_accessor *NAMES
    
    # Notably defined before we redifine initialize() to take no arguments
    DEFAULT = new(Foreign.defrenderparams).freeze

    def initialize
      super
      copy_from(DEFAULT)
    end

    def copy_from(other)
      NAMES.each do |get|
        set = (get.to_s + '=').to_sym
        self.send(set, other.send(get))
      end
    end
  end

  class HardwareParams < CPtr
    TYPE = 'P' + 'I'*11 + 'D'*2  #:nodoc:
    NAMES = [:font, :supported, :minwidth, :minheight,
      :maxwidth, :maxheight, :recwidth, :recheight,
      :mmwidth, :mmheight, :width, :height, :dimmul, :boldmul]  #:nodoc:

    struct_accessor *NAMES

    # Notably defined before we redifine initialize()
    DEFAULT = new(Foreign.defparams).freeze  #:nodoc:

    def initialize(with_ptr=nil)
      if with_ptr
        super(with_ptr)
      else
        super()
        copy_from(DEFAULT)
      end
    end

    def copy_from(other)
      NAMES.each do |get|
        set = (get.to_s + '=').to_sym
        self.send(set, other.send(get))
      end
    end

    def font
      self[:font] ? Font.new(self[:font]) : nil
    end
  end

  class Font < CPtr
    TYPE = 'PISS'  #:nodoc:
    NAMES = [:data, :height, :name, :shortname]  #:nodoc:
    struct_reader *(NAMES - [:data])
  end

  # Read-only output driver.  If you wish to pass a driver option to
  # AAlib::Context.init, select a driver from the Array returned by
  # AAlib.drivers.

  class Driver < CPtr
    TYPE = 'SS'  #:nodoc:
    NAMES = [:shortname, :name]  #:nodoc:
    struct_reader :shortname, :name

    def initialize(ptr) #:nodoc:
      super(ptr)
    end
  end

  # A graphics context opened using a particular driver along with any keyboard
  # and mouse drivers.  Two buffers are maintained: the image buffer and the
  # screen or text buffer.  AAlib::Context#putpixel is the primary method to
  # draw on the image buffer.  AAlib::Context#render converts the image buffer
  # to text, writing the result to the text buffer.  Text may be written
  # directly to the text buffer using AAlib::Context#puts and similar.  Note
  # that text written this way may be overwritten by AAlib::Context#render.
  # Finally, AAlib::Context#flush writes the text buffer to the screen.

  class Context < CPtr
    TYPE = 'PPP' + HardwareParams::TYPE*2 + 'IIIIPPPPPPIIIIIIIPPPP'  #:nodoc:

    NAMES = [:driver, :kbddriver, :mousedriver,  #:nodoc:
      HardwareParams::NAMES.collect {|sym| ("hardware_params_" + sym.to_s).to_sym },
      HardwareParams::NAMES.collect {|sym| ("driver_hardware_params_" + sym.to_s).to_sym },
      :mulx, :muly, :imgwidth, :imgheight,
      :imagebuffer, :textbuffer, :attrbuffer, :table,
      :filltable, :parameters, :cursorx, :cursory, :cursorstate,
      :mousex, :mousey, :buttons, :mousemode, :resizehandler,
      :driverdata, :kbddriverdata, :mousedriverdata].flatten

    # Returns the ratio of the widths of the image and text buffers.
    def mulx; end

    # Returns the ratio of the heights of the image and text buffers.
    def muly; end

    struct_reader :kbddriver, :parameters, :mulx, :muly

    # Closes the graphics context and resets the terminal if necessary.  Also
    # performs any keyboard and mouse uninitialization.

    def close
      Foreign.close(self)
      nil
    end

    # Initializes the keyboard for capture of key press events.  _Release_
    # determines whether or not one is interested in key release events as
    # well.  Note that key releases are unavailable when using a text terminal
    # (curses or slang drivers).

    def autoinitkbd(release=false)
      mode = 0
      mode |= SENDRELEASE if release
      r,rs = Foreign.autoinitkbd(self, mode)
      unless r == 1
        raise Error.new("failed to initialize keyboard")
      end
    end

    def autoinitmouse
      mode = 0
      r,rs = Foreign.autoinitmouse(self, mode)
      unless r == 1
        raise Error.new("failed to initialize mouse")
      end
    end

    # Returns a HardwareParams object representing the context's current
    # requested hardware params.

    def hardware_params
      HardwareParams.new(self + DL.sizeof('PPP'))
    end

    # Returns a HardwareParams object representing the context's current
    # hardware params as reported by the display driver.

    def driver_hardware_params
      HardwareParams.new(self + DL.sizeof('PPP') + DL.sizeof(HardwareParams::TYPE))
    end

    # Width of the screen and text buffer in characters.
    
    def scrwidth
      Foreign.scrwidth(self)[0]
    end

    # Height of the screen and text buffer in characters.

    def scrheight
      Foreign.scrheight(self)[0]
    end

    # Width of the image buffer in pixels. Note pixels are non-square. Use
    # mmwidth and mmheight to get the size of the screen in millimeters.

    def imgwidth
      Foreign.imgwidth(self)[0]
    end

    # Height of the image buffer in pixels. Note pixels are non-square. Use
    # mmwidth and mmheight to get the size of the screen in millimeters.
    
    def imgheight
      Foreign.imgheight(self)[0]
    end

    # Width of the screen in millimeters. Note this gives incorrect values on
    # text terminals where AAlib cannot get screen size or font information.

    def mmwidth
      Foreign.mmwidth(self)[0]
    end

    # Height of the screen in millimeters. Note this gives incorrect values on
    # text terminals where AAlib cannot get screen size or font information.

    def mmheight
      Foreign.mmheight(self)[0]
    end

    # Returns the editable image buffer as AAlib::CPtr (imgheight rows of
    # imgwidth chars packed into a single string)
    
    def image
      CPtr.new(Foreign.image(self)[0])
    end

    # Returns the editable text buffer as AAlib::CPtr (scrheight rows of
    # scrwidth characters packed in single string).  Writes to this buffer will
    # appear on screen after a #flush operation.
    
    def text
      CPtr.new(Foreign.text(self)[0])
    end

    # Returns the editable attr buffer as AAlib::CPtr (scrheight rows of
    # scrwidth chars packed in a single string).  Writes to this buffer will
    # modify text attributes on screen after a #flush operation.
    
    def attrs
      CPtr.new(Foreign.attrs(self)[0])
    end

    # Returns the current font.

    def font
      Font.new(Foreign.font(self)[0])
    end

    # Converts image buffer coordinates into text buffer coordinates.

    def img2scr(imgx, imgy)
      [imgx/mulx, imgy/muly]
    end
    
    # Converts the image buffer to ASCII on the text buffer.  _Renderparams_
    # should be a RenderParams specifying the parameters.  Screen coordinates
    # (x1, y1) and (x2, y2) define the column and row of the top left and
    # bottom right corners of the area to be rendered, respectively.
    # 
    # Note that #flush must be called to flush to the screen.
    #
    # The first call may take some time as the rendering tables are produced.

    def render(render_params, x1=0, y1=0, x2=scrwidth, y2=scrheight)
      AAlib.check_render_params(render_params)

      Foreign.render(self, render_params, x1, y1, x2, y2)
      self
    end

    # See #render.  This method performs a faster render using the default
    # rendering parameters.  Screen coordinates (x1, y1) and (x2, y2)
    # define the column and row of the top left and bottom right corners of the
    # area to be rendered, respectively.

    def fastrender(x1=0, y1=0, x2=scrwidth, y2=scrheight)
      Foreign.fastrender(self, x1, y1, x2, y2)
      self
    end

    # Flushes the text buffer to the screen, making it visible.  Note that the
    # image buffer is transformed to ascii-art and written to the text buffer
    # during #render.
    #
    # When using the save driver, this method causes the file to be written
    # out.

    def flush
      Foreign.flush(self)
      self
    end

    # Draw a pixel at _x_,_y_ in image coords in the desired _color_ (0-255).
    
    def putpixel(x, y, color)
      Foreign.putpixel(self, x, y, color)
      self
    end

    # Draw starting at _x_,_y_ in image coords using the pixels from _str_.

    def putpixels(x, y, str)
      pos = x + y*imgwidth
     
      # Sanity check
      if pos > imgwidth*imgheight
        pos = imgwidth*imgheight
      elsif pos < 0
        pos = 0
      end
      if pos+str.length > imgwidth*imgheight
        str = str[0, imgwidth*imgheight - pos]
      end

      image[pos] = str
      self
    end

    # Returns pixels from the imagebuffer from _x_,_y_ of length _len_ in
    # image coords and returns them as a String.

    def pixels(x, y, len)
      pos = x + y*imgwidth

      # Sanity check
      if pos > imgwidth*imgheight
        pos = imgwidth*imgheight
      elsif pos < 0
        pos = 0
      end
      if pos+len > imgwidth*imgheight
        len = imgwidth*imgheight - pos
      end

      image[pos, len]
    end

    # Writes string _str_ at _x_,_y_ in screen coords with attribute _attr_, a
    # AAlib::Attr.

    def puts(x, y, attr, str)
      Foreign.puts(self, x, y, attr, str)
      self
    end

    # Text in the box bounded by x1, y1 and x2, y2 in screen coords
    # is converted to an approximation of pixels on the image buffer to
    # facilitate image based manipulation of text.
    #
    # Note that a render operation must have been performed prior to calling
    # this method; this method will not work unless the rendering tables have
    # been calculated.
    #
    # This is a hack based on the backconvert function used in BB, the AA-lib
    # demo.  This is the technique used by the pager at the end of BB that
    # fades text in and out when paging.  It may not work in different versions
    # of AA-lib as it depends on some details not specified in the API.
    #
    # See also #pixels_from_text
   
    def backconvert(x1=0, y1=0, x2=scrwidth, y2=scrheight)
      sw = scrwidth
      size = DL.sizeof('I'*5)
      parameters = self[:parameters]

      (y1...y2).each do |y| # "..." excludes last value; ".." includes it
        (x1...x2).each do |x|
          pos = x + y*sw
          # n a unique int representing a char + attributes (ascii values range
          # from 0-255; adding 256*a where a is 0,1,2,3,4 (no SPECIAL) makes 5
          # pixel value for each ascii char depending on the attribute) and we
          # somehow use that backwards in a lookup table
          attr = attrs[pos, 1][0]
          attr = Attr::REVERSE if attr == Attr::SPECIAL # Can't backconv SPECIAL
          n = text[pos, 1][0] + 256*attr

          p = parameters[n*size, size].unpack('I*')

          putpixel(x*2, y*2, p[1])
          putpixel(x*2+1, y*2, p[0])
          putpixel(x*2, y*2+1, p[3])
          putpixel(x*2+1, y*2+1, p[2])
        end
      end
      self
    end

    # Returns two pixel-strings that, when drawn on the image buffer one above
    # the other, will render to a rough approximation of the text of length
    # _len_ currently on the text buffer at _x_, _y_ in screen coords.  In
    # other words, this converts text into pixels that may be painted and
    # otherwise manipulated on the image buffer.
    #
    # Note that a render operation must have been performed prior to calling
    # this method; this method will not work unless the rendering tables have
    # been calculated.
    #
    # See also #backconvert
    
    def pixels_from_text(x, y, len)
      pos = x + y*scrwidth

      # Sanity check
      if pos > scrwidth*scrheight
        pos = scrwidth*scrheight
      elsif pos < 0
        pos = 0
      end
      if pos+len > scrwidth*scrheight
        len = scrwidth*scrheight - pos
      end

      sw = scrwidth
      size = DL.sizeof('I'*5)
      parameters = self[:parameters]
      
      bytes1 = " "*len*2
      bytes2 = " "*len*2

      len.times do |i|
        pos = i + x + y*sw
        # n is a unique int representing a char with attributes (ascii values range
        # from 0-255; adding 256*a where a is 0,1,2,3,4 (no SPECIAL) makes 5
        # pixel value for each ascii char, one for each possible attribute) and we
        # somehow use that backwards in a lookup table
        attr = attrs[pos, 1][0]
        attr = Attr::REVERSE if attr == Attr::SPECIAL # Can't backconv SPECIAL
        n = text[pos, 1][0] + 256*attr

        p = parameters[n*size, size].unpack('I*')
        
        # These indices make no sense I know, but that's how aalib has them. I
        # can't decipher the reason, but I'm sure it's a good one. 
        bytes1[i*2] = p[1]
        bytes1[i*2+1] = p[0]
        bytes2[i*2] = p[3]
        bytes2[i*2+1] = p[2]
      end
 
      [bytes1, bytes2]
    end

    # Register a block to handle screen resize events.  The block will be
    # called with the Context when the screen size is changed and should
    # perform any redrawing necessary.

    def handle_resize
      handler = DL.callback('0P') do |ptr|
        resize
        yield self
      end
      Foreign.resize_handler(self, handler)
    end

    # Gets the next event.  If _wait_ is true, then #getevent will wait until
    # an event occurs, otherwise it will return immediately.

    def getevent(wait=true)
      check_kbd_init
      cwait = wait ? 1 : 0
      r,rs = Foreign.getevent(self, cwait)
      r
    end

    # Gets the next key event.  If _wait_ is true, then #getevent will wait
    # until an event occurs, otherwise it will return immediately.

    def getkey(wait=true)
      check_kbd_init
      cwait = wait ? 1 : 0
      r,rs = Foreign.getkey(self, cwait)
      r
    end

    # Moves the hardware cursor (if any) to position _x_, _y_ in screen coords.
    # To see the effect, #flush must be called.

    def gotoxy(x, y)
      Foreign.gotoxy(self, x, y)
      self
    end

    # Hides the hardware cursor (if any).  Returns self.

    def hidecursor
      Foreign.hidecursor(self)
      self
    end

    # Shoes the hardware cursor (if any).  Returns self.

    def showcursor
      Foreign.showcursor(self)
      self
    end

    # Returns an array of three values: the x,y location of the mouse in screen
    # coords and the button mask of the mouse.

    def getmouse
      Foreign.getmouse(self, x, y, b)
      self
    end

    # Hides the mouse pointer (if any).  Returns self.

    def hidemouse
      Foreign.hidemouse(self)
      self
    end

    # Resizes the image and text buffers and performs any other necessary
    # updates after a resize event.  This is automaically called prior to
    # running any resize handler.

    def resize
      Foreign.resize(self)
      self
    end

    # Copies the image buffer from _other_ to the image buffer of _self_.  Both
    # image buffers should be the same size.

    def copy_image_from(other)
      imgheight.times do |row|
        image[row*imgwidth] = other.image[other.imgwidth*row, imgwidth]
      end
    end

    private

    def check_kbd_init
      unless kbddriver
        raise Error.new("cannot get events with uninitialized keyboard")
      end
    end
  end

  # Output format used by AAlib.save

  class SaveFormat < CPtr
    TYPE = 'IIIIIIPSS'  #:nodoc:
    NAMES = [:width, :height, :pagewidth, :pageheight,
      :flags, :supported, :font, :formatname, :extension]  #:nodoc:

    # Flag to enable multiple pages
    USE_PAGES = 1  
    # Flag to use normal spaces (?)
    NORMAL_SPACES = 8  

    # Returns the name of the format
    def formatname; end

    # Returns the file extension including the dot.
    def extension; end

    struct_accessor :width, :height, :pagewidth, :pageheight
    struct_accessor :flags, :supported
    struct_reader :formatname, :extension

    class << self
      # Searches available save formats and returns the first that includes
      # _pattern_, a Regexp or String.  Raises exception if none found.

      def find(pattern)
        if pattern.kind_of? Regexp
          regexp = pattern
        else
          regexp = /#{pattern}/i
        end

        AAlib.formats.each do |format|
          return format if format.formatname =~ regexp
        end

        raise AAlib::Error.new("Could not find output format matching #{pattern}")
      end
    end
  end

  # Encapsulation of data required to save a file to disk.

  class SaveData < CPtr
    TYPE = 'SPP'  #:nodoc:
    NAMES = [:name, :format, :file]  #:nodoc:

    # Returns the file name that will be used for saving.
    def name; end

    struct_accessor :name, :format

    # Initializes a new SaveData to save to file _name_ with SaveFormat
    # _format_.  Passing a string _format_ uses the format returned by
    # AAlib::SaveFormat.find.  See AAlib::SaveFormat for options set with
    # flags; multiple flags should be logically OR'ed.
    #
    # The AA-lib docs claim that file extensions are added automatically, but
    # this appears to be false.

    def initialize(name, format, formatflags=0)
      super()

      self.name = name

      if format.kind_of? AAlib::SaveFormat
        self.format = format
      else
        self.format = AAlib::SaveFormat.find(format)
      end

      self.format.flags = formatflags
    end

    # Returns the AAlib::SaveFormat that will be used for saving
    def format
      SaveFormat.new(self[:format])
    end
  end
end
