# -*- ruby -*-

require 'rubygems'
require 'bundler/setup'
require 'rjack-tarpit'

RJack::TarPit.new( 'mojibake' ).define_tasks

desc "(Re-)generate config output files (requires 1.9)"
task :generate_config do
  if ( RUBY_VERSION.split( '.' ).map { |d| d.to_i } <=> [ 1, 9 ] ) >= 0
    require 'mojibake'
    mapper = MojiBake::Mapper.new
    open( "config/table.txt",  'w' ) { |fout| fout.puts( mapper.table ) }
    open( "config/table.json", 'w' ) { |fout| fout.puts( mapper.json  ) }
  else
    raise "Task generate_config requires Ruby 1.9 encoding support"
  end
end
