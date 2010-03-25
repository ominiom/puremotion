$LOAD_PATH.unshift(File.join(File.dirname(__FILE__), '..', 'lib'))

require 'puremotion'

def sample_path
  ::File.expand_path(::File.join(::File.dirname(__FILE__), "samples", "sample.ogv"))
end