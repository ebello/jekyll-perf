module Jekyll
  module Convertible
    
    alias orig_read_yaml read_yaml
    
    # Read the YAML frontmatter
    #   +base+ is the String path to the dir containing the file
    #   +name+ is the String filename of the file
    #
    # Returns nothing
    def read_yaml(base, name)      
      orig_read_yaml(base, name)
      
      self.content_blocks = Hash.new
      content_block_syntax = /^(-{3}content)\s+([^\n]*)\n(.*)^\1\s+\2\n?/m
      if self.content =~ content_block_syntax
        self.content.scan(content_block_syntax) do |match|
          self.content_blocks[$2.to_s] = $3
        end
        self.content.gsub!(content_block_syntax, '')
      end
    end

    # Add any necessary layouts to this convertible document
    #   +layouts+ is a Hash of {"name" => "layout"}
    #   +site_payload+ is the site payload hash
    #
    # Returns nothing
    def do_layout(payload, layouts)
      info = { :filters => [Jekyll::Filters], :registers => { :site => self.site } }

      # render and transform content (this becomes the final content of the object)
      payload["pygments_prefix"] = converter.pygments_prefix
      payload["pygments_suffix"] = converter.pygments_suffix
      # parse liquid inside all content blocks
      self.content_blocks.update(self.content_blocks){ |key, val| Liquid::Template.parse(val).render(payload, info) }
      payload["content_blocks"] = self.content_blocks
      
      begin
        self.content = Liquid::Template.parse(self.content).render(payload, info)
      rescue => e
        puts "Liquid Exception: #{e.message} in #{self.name}"
      end
      
      self.transform

      # output keeps track of what will finally be written
      self.output = self.content

      # recursively render layouts
      layout = layouts[self.data["layout"]]
      used = Set.new([layout])
      while layout
        # parse liquid inside all content blocks
        payload = payload.deep_merge({"content" => self.output, "page" => layout.data})
        # create a new hash for the layout content blocks, we don't want to change the original values
        layout_content_blocks = Hash[*layout.content_blocks.collect{|key, val| [key, Liquid::Template.parse(val).render(payload, info)] }.flatten]
        payload = payload.deep_merge({"content_blocks" => layout_content_blocks})

        begin
          self.output = Liquid::Template.parse(layout.content).render(payload, info)
        rescue => e
          puts "Liquid Exception: #{e.message} in #{self.data["layout"]}"
        end

        if layout = layouts[layout.data["layout"]]
          if used.include?(layout)
            layout = nil # avoid recursive chain
          else
            used << layout
          end
        end
      end
    end
  end
end