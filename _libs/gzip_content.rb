# from gzip jekyll plugin
# Copyright 2011 Cliff L. Biffle.  All Rights Reserved.
# You are free to use this file under the terms of the Creative Commons
# Attribution-Sharealike 3.0 Unported license, which can be found here:
# http://creativecommons.org/licenses/by-sa/3.0/

site = ARGV[0]

def should_compress(file)
  compressible_type(File.extname(file))# && large_enough(file)
end

def compressible_type(ext)
  [
    '.html',
    '.css',
    '.js',
    '.svg',
    '.appcache',
    #'.txt',
    #'.ttf',
    #'.atom',
    #'.stl',
  ].include?(ext)
end

def large_enough(file)
  File.size(file) > 200
end

Dir.chdir(site)
files = %x[ find . -type f ].split("\n").map do |f| 
  f[2,f.length]
end

zipped = files.select { |file| should_compress(file) }.collect{|file| 
  system "gzip -c #{file} > #{file}.gz"
  
  # delete original file
  File.delete(file)
  # rename compiled file - for Amazon's sake since it can't dynamically serve up gzipped content
  # browsers that don't support gzip will not work
  File.rename(file + '.gz', file)
}