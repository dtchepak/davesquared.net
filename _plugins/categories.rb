module Jekyll
    # Based on example from https://github.com/mojombo/jekyll/wiki/Plugins

    class CategoryIndex < Page
        def initialize(site, base, dir, category)
            @site = site
            @base = base
            @dir = dir
            @name = 'index.html'

            self.process(@name)
            self.read_yaml(File.join(base, '_layouts'), 'category.html')

            self.data['category'] = category
            self.data['title'] = "Posts tagged as #{category}"
        end
    end

    class CategoryGenerator < Generator
        safe true
        def generate(site)
            if site.layouts.key? 'category'
                dir = 'tagged'
                site.categories.keys.each do |category|
                    write_category_index(site, File.join(dir, category), category)
                end
            end
        end

        def write_category_index(site, dir, category)
            page = CategoryIndex.new(site, site.source, dir, category)
            page.render(site.layouts, site.site_payload)
            page.write(site.dest)
            site.static_files << page
        end
    end

end



