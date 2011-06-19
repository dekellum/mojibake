# -*- coding: utf-8 -*-

if ( RUBY_VERSION.split( '.' ).map { |d| d.to_i } <=> [ 1, 9 ] ) < 0
  raise "Requires ruby ~> 1.9 for String.encode support"
end

require 'mojibake/base'
require 'mojibake/mapper'
