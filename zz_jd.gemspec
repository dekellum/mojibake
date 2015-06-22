# jruby's jar-dependencies extension (which can't be disabled even
# with JARS_SKIP; despite jruby/jruby#1974) may attempt to load a
# gemspec even as part of `gem install`. As a rather silly workaround,
# add this other empty gemspec, as it currently won't choose between
# two in the same directory.
