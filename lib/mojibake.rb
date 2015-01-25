#--
# Copyright (c) 2011-2015 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You may
# obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

require 'mojibake/base'

require 'mojibake/json'

module MojiBake

  # Supports recovering Mojibake characters to the original text.
  class Mapper
    extend VersionSupport
    include JSONSupport

    if ( ruby_version_a <=> [1,9] ) >= 0 &&
        ( !jruby_version_a ||
          ( ( ( jruby_version_a <=> [1,6,5] ) >= 0 ) &&
            ( ( jruby_version_a <=> [1,7]   ) <  0 ) ) ||
          (   ( jruby_version_a <=> [1,7,4] ) >  0 ) )
      require 'mojibake/encoding'
      include EncodingSupport
    end

    def initialize( opts = {} )
      super()
      opts.map { |k,v| send( k.to_s + '=', v ) }
    end

    # Recover original characters from input using regexp, recursively.
    def recover( input, recursive = true )
      output = input.gsub( regexp ) { |moji| hash[moji] }

      # Only recurse if requested and substituted something (output
      # shorter) in this run.
      if recursive && ( output.length < input.length )
        recover( output )
      else
        output
      end
    end

  end
end
