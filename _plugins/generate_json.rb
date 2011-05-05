require 'json'
module Jekyll
  
  # do nothing on write so as to not conflict with regular staticfile
  class JsonFile < StaticFile
    def write(dest)
    end
  end
  
  class JsonBuilder < Generator
  
    safe true
    priority :high

    def generate(site)
      site.pages.select{|p| p.ext == ".json"}.each do |p|
        
        # load json into property so we can access with liquid later
        p.json = JSON.parse(p.content)
        
        # write out json file
        dir = File.join(site.dest, p.to_liquid["subfolder"])
        FileUtils.mkdir_p(dir)
        
        File.open(File.join(dir, p.name), 'w') do |f|
          f.write(p.content)
          f.close
        end
        
        # add to static files so it doesn't delete file in cleanup
        site.static_files << JsonFile.new(site, site.dest, p.to_liquid["subfolder"], p.name)
      end
      
    end

  end
  
end