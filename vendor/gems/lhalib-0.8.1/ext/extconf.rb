#----------------------------------
# extconf.rb
# $Revision: $
# $Date: $
#----------------------------------
require 'mkmf'

class Path

  def initialize()
    if File::ALT_SEPARATOR.nil?
      @file_separator = File::SEPARATOR
    else
      @file_separator = File::ALT_SEPARATOR
    end
  end

  def include(parent, child)
    inc = joint(parent, child)
    $INCFLAGS += " -I#{inc}"
    $CFLAGS += " -I#{inc}"
    inc
  end

  def joint(parent, child)
    parent + @file_separator + child
  end

end

def create_lhalib_makefile
  create_makefile("lhalib")
end

case RUBY_PLATFORM
when /mswin32/
  $CFLAGS += ' /W3'
when /cygwin/, /mingw/
  $defs << '-DNONAMELESSUNION'
end
create_lhalib_makefile

