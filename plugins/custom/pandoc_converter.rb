module Jekyll
  class PandocConverter < Converter
    safe true
    priority :high

    pygments_prefix "\n"
    pygments_suffix "\n"

    def setup
      return if @setup
      require 'pandoc-ruby'
      @setup = true
    rescue LoadError
      STDERR.puts 'You are missing a library required for Markdown. Please run:'
      STDERR.puts '  $ [sudo] gem install pandoc-ruby'
      raise FatalException.new("Missing dependency: pandoc-ruby")
    end
    
    def matches(ext)
      rgx = '(pandoc|pd|pdk|pmarkdown)'
      ext =~ Regexp.new(rgx, Regexp::IGNORECASE)
    end 

    def output_ext(ext)
      ".html"
    end

    def convert(content)
        setup
        PandocRuby.convert(content, {:f => :markdown, :to => :html5}, :mathml)
    end
  end
end
