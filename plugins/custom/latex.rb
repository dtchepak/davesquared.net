require 'pandoc-ruby'
module Jekyll
  class LatexBlock < Liquid::Block
    def initialize(tag_name, markup, tokens)
      super
    end

    def render(context)
      output = super.join
      PandocRuby.convert(output, {:f => :latex, :to => :html5 })
    end
  end
end

Liquid::Template.register_tag('latex', Jekyll::LatexBlock)
