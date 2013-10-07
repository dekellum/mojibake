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

module MojiBake
  VERSION = "1.1.2"

  module VersionSupport
    def ruby_version_a
      ver_to_a( RUBY_VERSION )
    end

    def jruby_version_a
      ver_to_a( JRUBY_VERSION ) if defined?( JRUBY_VERSION )
    end

    def ver_to_a( ver )
      ver.split( '.' ).map { |d| d.to_i }
    end
  end
end
