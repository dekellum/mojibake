# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'mojibake/base'

  s.version = MojiBake::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'json',            '~> 1.6.4'
  s.depend 'minitest',        '~> 2.10',       :dev
end
