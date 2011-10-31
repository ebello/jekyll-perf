site = ARGV[0]
basepath = ARGV[1]

def should_search(file)
  search_type(File.extname(file))
end

def search_type(ext)
  [
    '.css',
    '.js',
    '.json',
    '.html',
  ].include?(ext)
end

Dir.chdir(site)
files = %x[ find . -type f ].split("\n").map do |f| 
  f[2,f.length]
end

# get list of files to search
files_to_search = files.select{|f| should_search(f)}

# replace all instances of each file
files_to_search.each do |file|
  text = File.read(file)
  # easier to position file off the root
  files.each do |f|
    text = text.gsub(/(["'])\/?(#{f})/) {|s| $1 + basepath + '/' + $2}
  end
  File.open(file, "w") {|file|
    file.puts text
  }
end