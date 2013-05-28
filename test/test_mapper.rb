#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2011-2013 David Kellum
#
# Licensed under the Apache License, Version 2.0 (the "License"); you
# may not use this file except in compliance with the License.  You
# may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or
# implied.  See the License for the specific language governing
# permissions and limitations under the License.
#++

require 'rubygems'
require 'bundler/setup'

require 'minitest/unit'
require 'minitest/autorun'

require 'mojibake'

class TestMapper < MiniTest::Unit::TestCase
  include MojiBake

  def setup
    @mapper = Mapper.new
  end

  def test_nomatch_recover
    assert_equal( '', @mapper.recover( '' ) )
    assert_equal( 'ascii', @mapper.recover( 'ascii' ) )
    assert_equal( 'Â', @mapper.recover( 'Â' ) )
  end

  def test_simple_recover
    assert_equal( '[°]', @mapper.recover( '[Â°]' ) )
    assert_equal( '“quoted”', @mapper.recover( 'â€œquotedâ€�' ) )
    assert_equal( '“quoted”', @mapper.recover( 'âquotedâ€' ) )
  end

  def test_recursive_recover
    assert_equal( '°', @mapper.recover( 'Ã‚°' ) )
    assert_equal( 'AP – Greenlake', @mapper.recover( 'AP Ã¢â‚¬â€œ Greenlake' ) )
    assert_equal( 'you’re', @mapper.recover( 'youÃ¢â‚¬â„¢re' ) )
  end

end
