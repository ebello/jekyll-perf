require "json"

module Jekyll
  module Convertible

    alias_method :orig_do_layout, :do_layout

    def do_layout(payload, layouts)
      # send JSON through Liquid
      info = { :filters => [Jekyll::Filters], :registers => { :site => self.site, :page => payload['page'] } }

      if self.respond_to?('json')
        self.json = JSON.parse(self.render_liquid(self.json.to_json, payload, info)) if self.json
        payload["page"]["json"] = self.json
      end

      orig_do_layout(payload, layouts)
    end
  end
end