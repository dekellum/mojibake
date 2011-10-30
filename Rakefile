# -*- ruby -*-

$LOAD_PATH << './lib'

require 'rubygems'
gem     'rjack-tarpit', '~> 1.4'
require 'rjack-tarpit'

require 'mojibake/base'

t = RJack::TarPit.new( 'mojibake', MojiBake::VERSION )

t.specify do |h|
  h.developer( 'David Kellum', 'dek-oss@gravitext.com' )

  h.testlib = :minitest
  h.extra_dev_deps += [ [ 'minitest', '>= 2.1', '< 2.4' ],
                        [ 'json',     '~> 1.5.3' ] ]
  h.require_ruby_version( '>= 1.9' )

  h.url = 'http://github.com/dekellum/mojibake'
end

# Version/date consistency checks:

task :check_history_version do
  t.test_line_match( 'History.rdoc', /^==/, / #{ t.version } / )
end
task :check_history_date do
  t.test_line_match( 'History.rdoc', /^==/, /\([0-9\-]+\)$/ )
end

task :gem  => [ :check_history_version  ]
task :tag  => [ :check_history_version, :check_history_date ]
task :push => [ :check_history_version, :check_history_date ]

t.define_tasks
