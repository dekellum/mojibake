#!/opt/bin/jruby --1.9
# -*- coding: utf-8 -*-
#.hashdot.profile += jruby-shortlived

#--
# Copyright (c) 2011 David Kellum
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

ldir = File.join( File.dirname( __FILE__ ), "..", "lib" )
$LOAD_PATH.unshift( ldir ) unless $LOAD_PATH.include?( ldir )

require 'rubygems'
require 'minitest/unit'
require 'minitest/autorun'

require 'mojibake'

class TestMojiBake < MiniTest::Unit::TestCase

  def setup
    @mapper = MojiBake::Mapper.new
  end

  TEST_TREE = { "a" => { "b" => { "c" => {},
                                  "d" => {} } },
                "d" => { "b" => { "f" => {} } } }

  def test_char_tree
    assert_equal( TEST_TREE,
                  @mapper.char_tree( [ "abc", "abd", "dbf" ] ) )
  end

  def test_tree_flaten
    assert_equal( "ab(c|d)|dbf",
                  @mapper.tree_flatten( TEST_TREE ) )
  end

  def test_regexp
    re = Regexp.new( @mapper.tree_flatten( TEST_TREE ) )
    assert_match( re, "abc" )
    assert_match( re, "abd" )
    assert_match( re, "dbf" )
    refute_match( re, "ab" )
    refute_match( re, "abf" )
  end

  def test_nomatch_recover
    assert_equal( '', @mapper.recover( '' ) )
    assert_equal( 'ascii', @mapper.recover( 'ascii' ) )
    assert_equal( 'Â', @mapper.recover( 'Â' ) )
  end

  def test_simple_recover
    assert_equal( '[°]', @mapper.recover( '[Â°]' ) )
    assert_equal( '“', @mapper.recover( 'â€œ' ) )
  end

  def test_recursive_recover
    assert_equal( '°', @mapper.recover( 'Ã‚°' ) )
    assert_equal( 'AP – Greenlake', @mapper.recover( 'AP Ã¢â‚¬â€œ Greenlake' ) )
    assert_equal( 'you’re', @mapper.recover( 'youÃ¢â‚¬â„¢re' ) )
  end

end
