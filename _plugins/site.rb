module Jekyll
  class Site
    def domain
      config["domain"]
    end    

    def allpages
      pages + posts
    end
  end
end