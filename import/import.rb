require 'date'
require 'rss'

def convert(path)
    entries = get_entries path
    posts = entries.map { |x| get_post(x) }
    posts.each do |post|
        puts "Converting #{post.slug}..."
        f = File.new("_posts/#{post.jekyll_name}", 'w')
        f.write post.to_yaml
        f.close
    end
end

def get_entries(path)
    rss_source = File.open(path, 'r') { |f| f.read }
    rss = RSS::Parser.parse(rss_source)

    entries = rss.entries.find_all { |entry| is_published_post?(entry) }
end

def is_published_post?(entry)
    entry.categories.any? { |x| x.term.end_with?('#post') } and entry.links.any? { |x| x.rel == "alternate" }
end

def get_post(entry)
    post = Post.new
    post.id = entry.id.content
    post.title = entry.title.content
    post.tags = entry.categories.map { |x| x.term.sub('*', '+') }.select { |x| not x.end_with?('#post') }
    post.published = entry.published.content
    post.updated = entry.updated.content
    post.content = entry.content.content
    post.original_url = entry.links.find { |x| x.rel == "alternate" }.href
    return post
end

class Post
    attr_accessor :title
    attr_accessor :tags
    attr_accessor :published
    attr_accessor :updated
    attr_accessor :id
    attr_accessor :content
    attr_accessor :original_url

    def initialize()
        @tags = []
    end

    def to_yaml
        s = String.new
        s << "---\n"
        s << yaml_header("layout", "post")
        s << yaml_header("title", @title)
        s << yaml_header("blogger_id", @id)
        s << yaml_header_list("categories", @tags)
        s << yaml_header("date", @published)
        s << yaml_header("updated", @updated)
        s << "---\n"
        s << "\n"
        s << content
        s << "\n"
    end

    def jekyll_name()
        "#{@published.to_date}-#{slug}"
    end

    def slug()
        first_capture = 1
        match_last_url_section = /\/([^\/]*)$/
        @original_url[match_last_url_section, first_capture]
    end

    def yaml_header(name, value)
        escaped_value = value.to_s.gsub '"', '\"'
        "#{name}: \"#{escaped_value}\"\n"
    end

    def yaml_header_list(name, list)
        yaml_list = list.map { |x| "\"#{x}\"" }.join(', ')
        "#{name}: [#{yaml_list}]\n"
    end
end

if __FILE__ == $0
    convert ARGV[0]
end
