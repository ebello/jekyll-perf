module Jekyll
  class PageUrlTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      # for some reason liquid escapes quotes for strings
      @pageid = text.strip.gsub(/\"/, '')
    end

    def render(context)
      url = ""
      context.registers[:site].pages.each do |p|
        if @pageid == p.to_liquid["id"]
          url = p.subfolder + p.url
          break
        end
      end
      if url.empty?
        puts "ERROR - could not find url for page id: #{@pageid}"
      end
      return url
    end
  end
end

Liquid::Template.register_tag('url', Jekyll::PageUrlTag)