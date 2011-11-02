module Jekyll
  class StaticFile
    def to_liquid
      {
        "url" => destination('')
      }
    end
  end
end