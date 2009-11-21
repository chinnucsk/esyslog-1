require 'rake/clean'

INCLUDE = "include"

ERLC_FLAGS = "-I#{INCLUDE} +warn_unused_vars +warn_unused_import"

SRC = FileList['src/*.erl']
OBJ = SRC.pathmap("%{src,ebin}X.beam")

CLEAN.include("ebin/*.beam")

directory 'ebin'

rule ".beam" => ["%{ebin,src}X.erl"] do |t|
  sh "erlc -D EUNIT -pa ebin -W #{ERLC_FLAGS} -o ebin #{t.source}"
end

task :compile => ['ebin'] + OBJ

task :default => :compile

task :test => [:compile] do
  puts "Modules under test:"
  OBJ.each do |obj|
    obj[%r{.*/(.*).beam}]
    mod = $1
    test_output = `erl -pa ebin -run #{mod} test -run init stop`

    puts "#{mod}: #{test_output}"
  end
end

