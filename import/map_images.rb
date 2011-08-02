require 'pathname'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'uri'

def map_images(path)
    images = Pathname(path).
                each_child.
                select { |f| f.file? }.
                inject([]) { |memo, f| find_images(memo, f) }
    images.each { |x| puts x.to_s }
    images
end

def find_images(collection, file)
    s = Nokogiri::HTML(file.read)
    s.search("img").each do |node|
        collection << ImageInfo.new(file, node["src"])
        collection << ImageInfo.new(file, node.parent["href"]) if node.parent.name == "a"
    end
    collection
end

class ImageInfo
    attr_accessor :file
    attr_accessor :image
    attr_reader :new_image

    def initialize(file, image)
        @file = file
        @image = image
        path_fragments = image.split('/')
        @new_image = path_fragments[-2] + '-' + path_fragments[-1]
    end
    def to_s
        file.realpath.to_s + "\t" + image
    end
end

def download_all(image_map)
    image_urls = image_map.
        each do |image|
            p "Processing " + image.new_image
            #Skip stupid picasaweb redirect:
            image_url = image.image.sub("/s1600-h/", "/s1600/")
            download image_url, "images/" + image.new_image
        end
end

def download(url, dest, limit = 10)
    raise ArgumentError, 'HTTP redirect too deep' if limit <= 0

    uri = URI.parse(url)
    Net::HTTP.start(uri.host) do |http|
        resp = http.get(uri.path)
        if (resp.is_a? Net::HTTPRedirection) 
            download(resp['location'], dest, limit-1)
        else
            File.open(dest, "wb") { |f| f.write(resp.body) }
        end
    end
end


if __FILE__ == $0
    image_map = map_images(File.expand_path(ARGV[0]))
    download_all(image_map)
end
