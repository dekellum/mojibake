# -*- ruby -*-

gem 'rjack-tarpit', '~> 2.0'
require 'rjack-tarpit/spec'

RJack::TarPit.specify do |s|
  require 'mojibake/base'

  s.version = MojiBake::VERSION

  s.add_developer( 'David Kellum', 'dek-oss@gravitext.com' )

  s.depend 'json',            '>= 1.7.5',  '< 1.9'
  s.depend 'minitest',        '~> 4.7.4',     :dev
end
