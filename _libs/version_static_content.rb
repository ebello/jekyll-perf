require 'zlib'

site = ARGV[0]
cdn = ARGV[1]

def should_rename(file)
  far_future_expires_type(File.extname(file)) && !file.include?("apple-touch-icon")
end
  
def far_future_expires_type(ext)
  [
    '.css',
    '.js',
    '.ico',
    '.jpg',
    '.png',
    '.gif',
    '.svg',
  ].include?(ext)
end

def should_search(file)
  search_type(File.extname(file))
end

def search_type(ext)
  [
    '.css',
    '.js',
    '.json',
    '.html',
    '.appcache',
  ].include?(ext)
end

Dir.chdir(site)
files = %x[ find . -type f ].split("\n").map do |f| 
  f[2,f.length]
end

# make a hash of files that should be renamed, and what their CRC32 value is
farfuturefiles = Hash.new
files.select{|f| should_rename(f)}.collect{|f| 
  ext = File.extname(f)
  crc32 = Zlib.crc32(File.read(f)).to_s(16)
  farfuturefiles[f] = File.join(File.dirname(f), File.basename(f, ext)) + '.' + crc32 + ext
}

# get list of files to search
files_to_search = files.select{|f| should_search(f)}

# replace all instances of the static files
files_to_search.each do |file|
  text = File.read(file)
  # easier to position file off the root
  farfuturefiles.each do |key, val|
    val = val[2, val.length] if val.start_with?('./')
    text = text.gsub(/\/?#{key}/,"#{cdn}/#{val}")
  end
  File.open(file, "w") {|file|
    file.puts text
  }
end

# puts farfuturefiles

# rename the files based on their CRC32 value (ex. main.js will be renamed to main.ac208223.js)
farfuturefiles.each do |key, val|
  File.rename(key, val)
end