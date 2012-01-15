module Jekyll
  class CategoryListPage < Page
    def initialize(site, base, dir, layout, categories)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), layout + '.html')
      self.data['category_list'] = categories
    end
  end

  class CategoryListGenerator < Generator
    safe true

    def generate(site)
      return nil unless site.layouts.key? 'category_list'
      category_list = site.categories.keys
        .select { |c| not c.start_with? "+" }
        .sort.collect { |c| CategoryItem.new(c, site.categories[c].size) }

      dir = site.config['category_dir']

      page = CategoryListPage.new(site, site.source, dir, 'category_list', category_list)
      page.render(site.layouts, site.site_payload)
      page.write(site.dest)
      site.static_files << page
    end

    class CategoryItem
      def initialize(name, post_count)
        @name = name
        @post_count = post_count
      end
      def to_s
          @name
      end
      def to_liquid
        { "name" => @name, "post_count" => @post_count }
      end
    end
  end
end
