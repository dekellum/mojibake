W252 = Encoding::WINDOWS_1252
ISO8 = Encoding::ISO_8859_1
UTF8 = Encoding::UTF_8

s1 = 0x201C.chr( UTF8 ).force_encoding( ISO8 ).encode( UTF8 )
raise "failed 1" unless s1[ 1 ] == 0x80.chr( UTF8 )

s2 = 0x201C.chr( UTF8 ).force_encoding( W252 ).encode( UTF8 )
raise "failed 2" unless s2[ 1 ] == 0x20AC.chr( UTF8 )
