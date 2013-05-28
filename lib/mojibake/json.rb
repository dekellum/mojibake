#--
# Copyright (c) 2011-2013 David Kellum
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
require 'json'

module MojiBake

  module JSONSupport

    JSON_CONFIG = File.join( File.dirname( __FILE__ ),
                             '..', '..', 'config', 'table.json' )

    def initialize
      super
    end

    def config
      @config ||= JSON.parse( IO.read( JSON_CONFIG ) )
    end

    def hash
      @hash ||= config[ 'moji' ]
    end

    def regexp
      # Note use of Unicode mode for ruby 1.8's
      @regexp ||= Regexp.new( config[ 'regexp' ], 0, 'U' )
    end

    # table as self contained json-ready Hash
    def hash_to_json_object

      # Also use unicode escape for the interesting (effectively,
      # non-printable) subset of moji mappings.
      moji = hash.sort.map do |kv|
        kv.map do |s|
          s.codepoints.inject( '' ) do |r,i|
            if MojiBake::Mapper::INTEREST_CODEPOINTS.include?( i )
              r << sprintf( '\u%04X', i )
            else
              r << i.chr( Encoding::UTF_8 )
            end
          end
        end
      end

      { :mojibake => MojiBake::VERSION,
        :url => "https://github.com/dekellum/mojibake",
        :regexp => regexp.inspect[1...-1],
        :moji =>  Hash[ moji ] }
    end

    # Pretty formatted JSON serialized String for json_object
    def json
      # Generate and replace what become double escaped '\\u' UNICODE
      # escapes with single '\u' escapes. This is a hack but is
      # reasonably safe given that 'u' isn't normally escaped.  The
      # alterantive would be to hack JSON package or do the JSON
      # formatting ourselves.  Ideally JSON package would support
      # serialization using unicode escapes for the non-printable,
      # non-friendly chars. As of 1.6.1 it doesn't.
      JSON.pretty_generate( hash_to_json_object ).gsub( /\\\\u/, '\u' )
    end

  end

end
