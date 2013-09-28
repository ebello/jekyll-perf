module Jekyll
  
  # example: {% yaml john-rogers, video %}
  # first argument: page id
  # additional argument: key to search for
  # returns: value for key in YAML metadata
  
  class YamlTag < Liquid::Tag

    def initialize(tag_name, text, tokens)
      super
      # for some reason liquid escapes quotes for strings
      vars = text.strip.gsub(/\"/, '').split(',').collect(&:strip).compact
      @pageid = vars[0]
      @yamlkeys = vars.slice(1, vars.length - 1)
      puts "ERROR - no yaml key specified for #{@pageid}" if @yamlkeys.empty?
    end

    def render(context)
      result = nil
      context.registers[:site].allpages.each do |p|
        if @pageid == p.to_liquid["id"] || @pageid == p.to_liquid["uid"]
          result = p.to_liquid[@yamlkeys[0]]
          break
        end
      end
      if result.nil?
        puts "ERROR - yaml is blank for page id: \"#{@pageid}\", key: #{@yamlkey}"
      end
      return result
    end
  end
end

Liquid::Template.register_tag('yaml', Jekyll::YamlTag)