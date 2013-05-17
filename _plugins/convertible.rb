module Jekyll
  module Convertible
    
    alias orig_read_yaml read_yaml
    
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

    def render_all_layouts(layouts, payload, info)
      # recursively render layouts
      layout = layouts[self.data["layout"]]
      used = Set.new([layout])

      while layout
        payload = payload.deep_merge({"content" => self.output, "page" => layout.data})

        # create a new hash for the layout content blocks, we don't want to change the original values
        layout_content_blocks = Hash[*layout.content_blocks.collect{|key, val| [key, Liquid::Template.parse(val).render(payload, info)] }.flatten]
        payload = payload.deep_merge({"content_blocks" => layout_content_blocks})

        self.output = self.render_liquid(layout.content,
                                         payload.merge({:file => self.data["layout"]}),
                                         info)

        if layout = layouts[layout.data["layout"]]
          if used.include?(layout)
            layout = nil # avoid recursive chain
          else
            used << layout
          end
        end
      end
    end

    def do_layout(payload, layouts)
      info = { :filters => [Jekyll::Filters], :registers => { :site => self.site, :page => payload['page'] } }

      # render and transform content (this becomes the final content of the object)
      payload["pygments_prefix"] = converter.pygments_prefix
      payload["pygments_suffix"] = converter.pygments_suffix

      # parse liquid inside all content blocks
      self.content_blocks.update(self.content_blocks){ |key, val| Liquid::Template.parse(val).render(payload, info) }
      payload["content_blocks"] = self.content_blocks

      self.content = self.render_liquid(self.content,
                                        payload.merge({:file => self.name}),
                                        info)
      self.transform

      # output keeps track of what will finally be written
      self.output = self.content

      self.render_all_layouts(layouts, payload, info)
    end
  end
end