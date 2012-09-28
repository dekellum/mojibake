W252 = Encoding::WINDOWS_1252
ISO8 = Encoding::ISO_8859_1
UTF8 = Encoding::UTF_8

10.times do
  [ W252, ISO8 ].shuffle.each do |a_encoding|
    c = 0x201C.chr( UTF8 ).force_encoding( a_encoding ).encode( UTF8 )
    puts c
    mchar = ( a_encoding == W252 ) ? 0x20AC : 0x80
    raise "failed with #{a_encoding}" unless c[1] == mchar.chr( UTF8 )
  end
end
