module Jekyll

  class JsonConverter < Converter
    safe true

    def matches(ext)
      ext =~ /\.json/i
    end

    def output_ext(ext)
      ".html"
    end

    def convert(content)
      content
    end
  end

  class JsonRawConverter < Converter
    safe true

    def matches(ext)
      ext =~ /\.raw-json/i
    end

    def output_ext(ext)
      ".json"
    end

    def convert(content)
      content
    end
  end

end