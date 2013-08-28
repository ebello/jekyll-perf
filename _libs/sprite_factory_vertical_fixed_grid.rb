require 'sprite_factory'

module SpriteFactory
  module Layout

    def self.verticalfixedgrid
      VerticalFixedGrid
    end

    module VerticalFixedGrid

      def self.layout(images, options = {})

        raise NotImplementedError, ":verticalfixedgrid layout does not support fixed :width/:height option" if options[:width] || options[:height]

        max_width = images.map{|i| i[:width]}.max
        max_height = images.map{|i| i[:height]}.max
        y = 0

        images.each do |i|

          i[:cssx] = 0
          i[:x]    = 0

          i[:cssh] = max_height
          i[:cssy] = y
          i[:y]    = i[:cssy]
            
          y += i[:cssh]

        end
        { :width => max_width, :height => y }
      end

    end
  end
end

if ARGV.length > 0
  folders = ARGV[0].split(",")
  SpriteFactory.layout = :verticalfixedgrid
  SpriteFactory.report  = true

  folders.each do |folder|
    SpriteFactory.run!(folder, :nocss => true)
  end
end