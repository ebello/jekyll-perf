module Jekyll
  
  # example: {% json john-rogers, video %}
  # first argument: page id
  # additional arguments: json keys to search for
  
  # example: {% json john-rogers, image, url %}
  # will pull back the url in this JSON string: "image": {"url": "/images/casestudies/BASF_web3.jpg", "width": 468, "height": 468}
  
  class JsonTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      # for some reason liquid escapes quotes for strings
      vars = text.strip.gsub(/\"/, '').split(',').collect(&:strip).compact
      @pageid = vars[0]
      @jsonkeys = vars.slice(1, vars.length - 1)
      puts "ERROR - no json keys specified for #{@pageid}" if @jsonkeys.empty?
    end

    def render(context)
      result = nil
      context.registers[:site].pages.each do |p|
        if @pageid == p.to_liquid["id"]
          
          result = p.json
          @jsonkeys.each do |key|
            result = result[key]
          end
          break
        end
      end
      if result.nil?
        puts "ERROR - json is blank for page id: \"#{@pageid}\", json keys: #{@jsonkeys}"
      end
      return result
    end
  end
end

Liquid::Template.register_tag('json', Jekyll::JsonTag)