require 'rmagick'

# Takes a list of file names, appends each image left-to-right, deletes them, then outputs the composite image using the first file name passed in

x = 0
width = 0
ARGV.each_with_index do |arg, index|
  img = Magick::Image.read(arg).first
  if index == 0
    width = img.columns
    @sprite = Magick::Image.new(width * ARGV.length, img.rows) {
      self.background_color = 'none'
    }
  end

  @sprite.composite!(img, width * index, 0, Magick::OverCompositeOp)

  File.delete(arg)
end

@sprite.write(ARGV[0])