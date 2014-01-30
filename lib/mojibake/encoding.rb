#--
# Copyright (c) 2011-2014 David Kellum
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

  # Mixin for the actual (ruby 1.9 backed) encoding support to define
  # the mojibake mapping table and regex.
  module EncodingSupport

    W252 = Encoding::WINDOWS_1252
    ISO8 = Encoding::ISO_8859_1
    UTF8 = Encoding::UTF_8

    # The 8-bit high-order characters assigned in Windows-1252, as UTF8.
    # This is actually a superset of ISO-8859-1 high order set,
    # including in particular, punctuation characters like EM DASH and
    # RIGHT DOUBLE QUOTATION MARK. These are the most common problem
    # chars in English and probably most latin languages.
    HIGH_ORDER_CHARS =
      ( Array( 0x80..0xFF ) - [ 0x81, 0x8D, 0x8F, 0x90, 0x9D ] ).
      map { |i| i.chr( W252 ).encode( UTF8 ) }.
      sort

    # Additional Unicode codepoints of mojibake potential, like alt
    # whitespace, C1 control characters, and BOMs.
    INTEREST_CODEPOINTS =
      [ 0x0080..0x009F, # ISO/Unicode C1 control codes.
        0x00A0,         # NO-BREAK SPACE
        0x2000..0x200B, # EN QUAD ... ZERO WIDTH SPACE
        0x2060,         # WORD JOINER
        0xfeff,         # ZERO WIDTH SPACE, BYTE-ORDER-MARK (BOM)
        0xfffd,         # REPLACEMENT CHARACTER
        0xfffe ].       # UNASSIGNED, BAD BOM
      map { |i| Array( i ) }.
      flatten.
      sort

    INTEREST_CHARS = INTEREST_CODEPOINTS.map { |c| c.chr( UTF8 ) }

    # Mojibake candidate characters in reverse; HIGH_ORDER_CHARS and
    # lowest codepoints have highest precedence.
    CANDIDATE_CHARS = ( HIGH_ORDER_CHARS + INTEREST_CHARS ).reverse

    # Include Windows-1252 transcodes in map (default: true)
    attr_accessor :map_windows_1252

    # Include ISO-8859-1 transcodes in map (default: true)
    attr_accessor :map_iso_8859_1

    # Include permutations between ISO-8859-1 and Windows-1252
    # (default: true).  This covers ambiguities of C1 control codes.
    attr_accessor :map_permutations

    def initialize
      super
      @map_windows_1252 = true
      @map_iso_8859_1   = true
      @map_permutations = true
    end

    # Return Hash of mojibake UTF-8 2-3 character sequences to original
    # UTF-8 (recovered) characters
    def hash
      @hash ||= CANDIDATE_CHARS.inject( {} ) do |h,c|

        # Mis-interpret as ISO-8859-1, and encode back to UTF-8
        moji_8 = c.encode( UTF8, ISO8 )
        h[moji_8] = c if @map_iso_8859_1

        # Mis-interpret as Windows-1252, and encode back to UTF-8
        moji_w = c.encode( UTF8, W252, :undef => :replace )
        h[moji_w] = c if @map_windows_1252

        if @map_permutations
          # Also add permutations of unassigned Windows-1252 chars to
          # the 8bit equivalent.
          i = 0
          moji_w.each_codepoint do |cp|
            if cp == 0xFFFD
              moji_n = moji_w.dup
              moji_n[i] = moji_8[i]
              h[moji_n] = c
            end
            i += 1
          end
        end

        h
      end
    end

    # Return pretty table formatting of hash (array of lines)
    def table
      lines = [ "# -*- coding: utf-8 -*- mojibake: #{MojiBake::VERSION}" ]
      lines << regexp.inspect
      lines << ""
      lines << "Moji\tUNICODE  \tOrg\tCODE"
      lines << "+----\t---- ---- ----\t-----\t---+"
      lines += hash.sort.map do |moji,c|
        "[%s]\t%s\t[%s]\t%s" %
          [ moji, codepoints_hex( moji ), c, codepoints_hex( c ) ]
      end
      lines
    end

    # A Regexp that will match any of the mojibake sequences, as
    # found in hash.keys.
    def regexp
      @regexp ||= Regexp.new( tree_flatten( char_tree( hash.keys ) ) )
    end

    def char_tree( seqs )
      seqs.inject( {} ) do |h,seq|
        seq.chars.inject( h ) do |hs,c|
          hs[c] ||= {}
        end
        h
      end
    end

    def tree_flatten( tree )
      cs = tree.sort.map do |k,v|
        o = regex_encode( k )
        unless v.empty?
          c = tree_flatten( v )
          o << if c =~ /^\[.*\]$/ || v.length == 1
                 c
               else
                 '(' + c + ')'
               end
        end
        o
      end
      if cs.find { |o| o =~ /[()|\[\]]/ }
        cs.join( '|' )
      else
        if cs.length > 1
          '[' + cs.inject(:+) + ']'
        else
          cs.first
        end
      end
    end

    # Unicode hex dump of codepoints
    def codepoints_hex( s )
      s.codepoints.map { |i| sprintf( "%04X", i ) }.join( ' ' )
    end

    def regex_encode( c )
      i = c.each_codepoint.next #only one
      if INTEREST_CODEPOINTS.include?( i )
        sprintf( '\u%04X', i )
      else
        Regexp.escape( c )
      end
    end

  end
end
