module Jekyll
  class ContentForTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      # for some reason liquid escapes quotes for strings
      @content_block = text.strip.gsub(/\"/, '')
    end

    def render(context)
      context["content_blocks"][@content_block]
    end
  end
end

Liquid::Template.register_tag('content_for', Jekyll::ContentForTag)