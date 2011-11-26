module Jekyll
  class Page
    attr_accessor :content_blocks, :json
    
    def absolute_url
      if site.domain
        site.domain + subfolder + url
      else
        puts '*** WARNING: domain in _config.yml is blank. This is used to generate an absolute url for a page.'
        subfolder + url
      end
    end
    
    def subfolder
      @dir
    end
    
    def hierarchy_array
      subfolder.split('/')
    end
    
    def hierarchy_at(levels_up)
      arr = hierarchy_array
      if (arr.size - levels_up > -1)
        arr = arr.first(arr.size - levels_up)
      end
      arr.join('/')
    end
    
    alias orig_to_liquid to_liquid
    def to_liquid
      # we want index pages to be included with the navigation one level above, but only if it's not on the first level
      orig_to_liquid.deep_merge({
        "subfolder" => (index? && hierarchy_array.size > 2) ? hierarchy_at(1) : subfolder,
        "hierarchy_array" => hierarchy_array,
        "parent" => hierarchy_at(1),
        "absolute_url" => absolute_url,
        "json" => json
      })
    end
  end
end