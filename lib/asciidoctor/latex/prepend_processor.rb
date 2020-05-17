require 'asciidoctor'
require 'asciidoctor/extensions'

module Asciidoctor::Latex

  # THIS CLASS IS NO LONGER USED
  # See 'inject_html.rb'
  # Prepend lines to a document

  class ClickStyleInsert < Asciidoctor::Extensions::Preprocessor

    def putline line
      @@line_array += [line, ""]
    end

    def process document, reader

      warn "Entering ClickStyleInsert".magenta if $VERBOSE

      @@line_array = []

      return reader if reader.eof?

      putline '++++'
      putline '<style>'
      putline '.click .title { color: blue; }'
      putline '</style>'
      putline '++++'

      reader.unshift_lines @@line_array
      reader
    end

  end


end
