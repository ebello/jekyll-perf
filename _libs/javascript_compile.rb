require 'uglifier'

site = ARGV[0]

def should_compile_js(file)
  File.extname(file) == '.js' && !File.basename(file, File.extname(file)).end_with?('.min')
end

Dir.chdir(site)
files = %x[ find . -type f ].split("\n").map do |f| 
  f[2,f.length]
end

# get list of files to compile
javascripts = files.select{ |f| should_compile_js(f) }

# replace all instances of the static files
javascripts.each do |file|

  # create compiled file
  File.open(file + ".compiled", "w") {|f| 
    f.puts Uglifier.compile(File.read(file))
  }
  
  # delete original file
  File.delete(file)
  # rename compiled file
  File.rename(file + '.compiled', file)
end