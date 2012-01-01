require 'pathname'
require 'nokogiri'
require 'open-uri'
require 'net/http'
require 'uri'

def update_links(path)
    files = Pathname(path).
                each_child.
                select { |f| f.file? }
    files.each do |x| 
        p "Updating " + x.to_s
        s = IO.read(x.realpath.to_s)
        s.gsub!("davesquared.blogspot.com", "davesquared.net")
        s.gsub!("www.davesquared.net", "davesquared.net")
        IO.write(x.realpath.to_s, s)
    end
end

if __FILE__ == $0
    working_dir = File.expand_path(ARGV[0])
    update_links(working_dir)
end
