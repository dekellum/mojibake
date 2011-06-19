
module MojiBake
  class Mapper

    W252 = Encoding::WINDOWS_1252
    ISO8 = Encoding::ISO_8859_1
    UTF8 = Encoding::UTF_8

    # The 8-bit high-order characters assigned in Windows-1252, as UTF8.
    # This is actually a superset of ISO-8859-1 high order set,
    # including in particular, punctuation characters like EM DASH and
    # RIGHT DOUBLE QUOTATION MARK. These are the most common problem
    # chars in English and probably most latin languages.
    HIGH_ORDER_CHARS =
      ( ( 0x80..0xFF ).to_a - [ 0x81, 0x8D, 0x8F, 0x90, 0x9D ] ).
      map    { |i| i.chr( W252 ).encode( UTF8 ) }.
      sort

    # Additional Unicode characters of mojibake issue, like alt
    # whitespace and BOM
    INTEREST_CHARS =
      [ (0x0080..0x009F).to_a, # ISO,Unicode C1 control codes.
        0x00A0,                # NO-BREAK SPACE
        (0x2000..0x200B).to_a, # EN QUAD ... ZERO WIDTH SPACE
        0x2060,                # WORD JOINER
        0xfeff,                # ZERO WIDTH SPACE, BYTE-ORDER-MARK (BOM)
        0xfffd,                # REPLACEMENT CHARACTER
        0xfffe                 # UNASSIGNED, BAD BOM
      ].
      flatten.
      map { |c| c.chr( UTF8 ) }.
      sort

    # Include Windows-1252 transcodes in map (default: true)
    attr_accessor :map_windows_1252

    # Include ISO-8859-1 transcodes in map (default: true)
    attr_accessor :map_iso_8859_1

    # Include perumutation between ISO-8859-1 and Windows-1252 in map
    # This covers ambiguities of C1 control codes (default: true)
    attr_accessor :map_permutations

    def initialize( options = {} )
      @map_windows_1252 = true
      @map_iso_8859_1   = true
      @map_high_order   = true
      @map_permutations = true

      options.map { |k,v| send( k.to_s + '=', v ) }
    end

    # Mojibake candidate characters in reverse; HIGH_ORDER_CHARS and
    # lowest codepoints have highest precedence.
    CANDIDATE_CHARS = ( HIGH_ORDER_CHARS + INTEREST_CHARS ).reverse

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

    # Return pretty formatted table formatting of hash (as array of
    # lines)
    def table
      ( [ "Moji\tUNICODE  \tOrg\tCODE",
          "-----\t---- ---- ----\t-----\t----" ] +
        hash.sort.map { |moji,c|
          "[%s]\t%s\t[%s]\t%s" %
            [ moji, codepoints_hex( moji ), c, codepoints_hex( c ) ] } )
    end

    # A Regexp that will match any of the mojibake sequences, as
    # found in hash.keys.
    def regexp
      @regexp ||= Regexp.new( tree_flatten( char_tree( self.hash.keys ) ) )
    end

    # Recover original characters from input using regexp, recursively.
    def recover( input, recursive = true )
      output = input.gsub( regexp ) { |moji| hash[moji] }

      # Only recurse if requested and subsituted something (output
      # shorter) in this run.
      if recursive && ( output.length < input.length )
        recover( output )
      else
        output
      end
    end

    def char_tree( seqs )
      seqs.inject( {} ) do |h,seq|
        seq.chars.inject( h ) do |hs,c|
          hs[c] ||= Hash.new { |hss,k| hss[k] = {} }
        end
        h
      end
    end

    def tree_flatten( tree )
      tree.map { |k,v|
        o = Regexp.escape( k )
        unless v.empty?
          o << '(' unless v.length == 1
          o << tree_flatten( v )
          o << ')' unless v.length == 1
        end
        o }.join( '|' ).force_encoding( "UTF-8" )
      #FIXME: Join looses encoding so force, jruby bug?
    end

    # Unicode hex dump of codepoints
    def codepoints_hex( s )
      s.codepoints.map { |i| sprintf( "%04X", i ) }.join( ' ' )
    end

  end
end
