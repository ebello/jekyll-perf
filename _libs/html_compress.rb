site = ARGV[0]
COMPRESSOR_JAR = ARGV[1]

def is_html(file)
  File.extname(file) == '.html'
end

def compress_html(file)
  system "java -jar #{COMPRESSOR_JAR} --remove-intertag-spaces --compress-js --js-compressor closure -o #{file}.compressed #{file}"
end

Dir.chdir(site)
files = %x[ find . -type f ].split("\n").map do |f| 
  f[2,f.length]
end

# get list of files to compress
html = files.select{|f| is_html(f)}

# replace all existing html files
html.each do |file|
  compress_html(file)
  # delete original file
  File.delete(file)
  # rename compiled file
  File.rename(file + '.compressed', file)
end