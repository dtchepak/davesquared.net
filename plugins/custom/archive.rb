# Original source: 
#   https://github.com/josegonzalez/josediazgonzalez.com/raw/master/_plugins/archive.rb
# Modifications for this site:
# * Removing per-day archives
# * Replaced multiple archive template types with generic 'archive_index'
# * Passing posts to ArchiveIndex rather than recollating.
module Jekyll

  class ArchiveIndex < Page
    def initialize(site, base, dir, layout, posts)
      @site = site
      @base = base
      @dir = dir
      @name = 'index.html'

      self.process(@name)
      self.read_yaml(File.join(base, '_layouts'), layout + '.html')
      self.data['archive_posts'] = posts

      year, month, day = dir.split('/')
      self.data['year'] = year.to_i
      month and self.data['month'] = month.to_i
      day and self.data['day'] = day.to_i
    end
  end

  class ArchiveGenerator < Generator
    safe true
    attr_accessor :collated_posts

    def generate(site)
      return nil unless site.layouts.key? 'archive_index'

      self.collated_posts = {}
      collate(site)

      self.collated_posts.keys.each do |y|
        write_archive_index(site, y.to_s, posts_for(y))
        self.collated_posts[ y ].keys.each do |m|
          write_archive_index(site, "%04d/%02d" % [ y.to_s, m.to_s ], posts_for(y, m))
        end
      end
    end

    def write_archive_index(site, dir, posts)
      archive = ArchiveIndex.new(site, site.source, dir, 'archive_index', posts)
      archive.render(site.layouts, site.site_payload)
      archive.write(site.dest)
      site.static_files << archive
    end

    def posts_for(year, month = nil)
      self.collated_posts[ year ]
        .select { |m, v| month.nil? or m == month }
        .collect { |m, v| v}
        .flatten
    end

    def collate(site)
      site.posts.reverse.each do |post|
        y, m = post.date.year, post.date.month
        self.collated_posts[ y ] = {} unless self.collated_posts.key? y
        self.collated_posts[ y ][ m ] = [] unless self.collated_posts[y].key? m
        self.collated_posts[ y ][ m ].push(post)
      end
    end
  end
end
