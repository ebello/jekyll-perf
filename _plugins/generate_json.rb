module Jekyll
  
  class JsonFile < Page
    def initialize(site, base, dir, name, content)
      self.data = {}
      self.content = content

      # convert to .raw-json so we can output the file as .json instead of .html using a converter
      super(site, base, dir, name.gsub(/\.json/, ".raw-json"))
    end

    def read_yaml(*)
      # Do nothing because we don't want a layout
    end
  end
  
  class JsonBuilder < Generator
  
    safe true
    priority :high

    def generate(site)
      site.allpages.select{|p| p.ext == ".json"}.each do |p|

        unless p.to_liquid["makehtml"] == false
          # set json property to content. it will be converted to actual JSON in do_layout.
          p.json = p.content
          
          site.pages << JsonFile.new(site, site.source, p.to_liquid["subfolder"], p.name, p.content)
        end
      end
      
    end

  end
  
end