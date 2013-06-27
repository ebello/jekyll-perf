require "jekyll-assets"
require "jekyll-assets/compass"

# following is a workaround for keeping copyrights intact
# https://github.com/ixti/jekyll-assets/issues/34
require "sprockets/uglifier_compressor"

class Sprockets::UglifierCompressor
  def evaluate(context, locals, &block)
    if context.pathname.to_s =~ /\.min\./
      data
    else
      # Feature detect Uglifier 2.0 option support
      if Uglifier::DEFAULTS[:copyright]
        # Uglifier < 2.x
        Uglifier.new(:copyright => true).compile(data)
      else
        # Uglifier >= 2.x
        Uglifier.new(:comments => :copyright).compile(data)
      end
    end
  end
end