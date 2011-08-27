#--
# Copyright (c) 2011 David Kellum
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

require 'mojibake/mapper'
require 'json'

module MojiBake

  class Mapper

    # table as self contained json-ready Hash
    def json_object
      { :mojibake => MojiBake::VERSION,
        :url => "https://github.com/dekellum/mojibake",
        :regexp => regexp.inspect[1...-1],
        :moji => Hash[ hash.sort ] }
    end

    # Pretty formatted JSON serialized String for json_object
    def json
      JSON.pretty_generate( json_object )
    end

  end
end
