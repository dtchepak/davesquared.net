module Jekyll
    require 'sass'
    class SassyCssConverter < Converter
        safe true
        priority :low

        def matches(ext)
            ext =~ /scss/i
        end

        def output_ext(ext)
            ".css"
        end

        def convert(content)
            sass_engine = Sass::Engine.new(content, { :syntax => :scss })
            sass_engine.render
        end
    end
end

