require 'rmagick'
include Magick

site = ARGV[0]
image2xfolder = ARGV[1]

def is_img(file)
  search_type(File.extname(file))
end

def search_type(ext)
  [
    '.png',
    '.jpg',
    '.jpeg',
    '.gif',
  ].include?(ext)
end

files = %x[ find . -type f | grep -v '#{site}' | grep '#{image2xfolder}' ].split("\n").map do |f| 
  f[2,f.length]
end

images2x = files.select{|f| is_img(f)}

images2x.each do |imgfile|
  generatehalfsize = true
  fullsize = File.new(imgfile)
  halfsizepath = fullsize.path.gsub(image2xfolder, '')
  # if the half size image already exists, only make a new one if the mod time of the 2x is later than the half size
  if File.exist?(halfsizepath)
    if (fullsize.mtime < File.new(halfsizepath).mtime)
      generatehalfsize = false 
    end
  end
  if generatehalfsize
    fimg = Image.read(imgfile)
    himg = fimg[0].scale(0.5)
    himg.write(halfsizepath)
  end
end