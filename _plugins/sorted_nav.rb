module Jekyll
  class SortedNavigationBuilder < Generator
  
    safe true
    priority :high

    def generate(site)
      site.config['sorted_navigation'] = site.pages.select{|p| !p.to_liquid["navorder"].nil?}.sort_by! { |p| p.to_liquid["navorder"] }
    end

  end
end