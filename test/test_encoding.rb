#!/usr/bin/env ruby
# -*- coding: utf-8 -*-
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2011-2015 David Kellum
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

class TestEncoding < MiniTest::Unit::TestCase
  include MojiBake

  MAPPER = Mapper.new

  TEST_TREE = { "a" => { "b" => { "c" => {},
                                  "d" => {} } },
                "d" => { "b" => { "f" => {} } } }

  # These only test with Ruby 1.9 support
  if defined?( MAPPER.char_tree )

    def test_init_options
      assert_equal( true, Mapper.new.map_iso_8859_1 )
      m = Mapper.new( :map_iso_8859_1 => false )
      assert_equal( false, m.map_iso_8859_1 )
    end

    def test_char_tree
      assert_equal( TEST_TREE,
                    MAPPER.char_tree( [ "abc", "abd", "dbf" ] ) )
    end

    def test_tree_flaten
      assert_equal( "ab[cd]|dbf",
                    MAPPER.tree_flatten( TEST_TREE ) )
    end

    def test_regexp
      re = Regexp.new( MAPPER.tree_flatten( TEST_TREE ) )
      assert_match( re, "abc" )
      assert_match( re, "abd" )
      assert_match( re, "dbf" )

      refute_match( re, "ab" )
      refute_match( re, "abf" )

      assert_equal(  "xbf" , "abdbf".gsub( re, 'x' ) )
      assert_equal(  "dbf" , "abdbf".gsub( re, 'd' ) )
    end

  end

end
