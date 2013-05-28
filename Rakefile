# -*- ruby -*-

require 'rubygems'
require 'bundler/setup'
require 'rjack-tarpit'

RJack::TarPit.new( 'mojibake' ).define_tasks

desc "(Re-)generate config output files (requires 1.9)"
task :generate_config do
  require 'mojibake'
  mapper = MojiBake::Mapper.new
  if defined?( mapper.table )
    open( "config/table.txt",  'w' ) { |fout| fout.puts( mapper.table ) }
    open( "config/table.json", 'w' ) { |fout| fout.puts( mapper.json  ) }
  else
    raise "Task generate_config requires Ruby 1.9 encoding support"
  end
end
