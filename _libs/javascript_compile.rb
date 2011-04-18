site = ARGV[0]
COMPILER_JAR = ARGV[1]

def is_js(file)
  File.extname(file) == '.js'
end

def should_compile(file)
  !File.basename(file, File.extname(file)).end_with?('.min')
end

def compile_js(file, should_compile)
  compiler_options = {}
  compiler_options['--js'] = file
  compiler_options['--js_output_file'] = file + '.compiled'
  if (should_compile)
    compiler_options['--compilation_level'] = 'SIMPLE_OPTIMIZATIONS'
    # compiler_options['--compilation_level'] = 'ADVANCED_OPTIMIZATIONS'
  else
    compiler_options['--compilation_level'] = 'WHITESPACE_ONLY'
  end

  system "java -jar #{COMPILER_JAR} #{compiler_options.to_a.join(' ')}"
end

Dir.chdir(site)
files = %x[ find . -type f ].split("\n").map do |f| 
  f[2,f.length]
end

# get list of files to compile
javascripts = files.select{|f| is_js(f)}

# replace all instances of the static files
javascripts.each do |file|
  compile_js(file, should_compile(file))
  # delete original file
  File.delete(file)
  # rename compiled file
  File.rename(file + '.compiled', file)
end