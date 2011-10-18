require "cgi"

module Jekyll
  module Filters
    def urlencode(input)
      CGI::escape(input)
    end
  end
end