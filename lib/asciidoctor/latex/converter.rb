require 'asciidoctor'
require 'asciidoctor/extensions' unless RUBY_ENGINE == 'opal'
require 'asciidoctor/latex/core_ext/colored_string'
require 'asciidoctor/latex/ent_to_uni'
require 'asciidoctor/latex/node_processors'
require 'asciidoctor/latex/tex_block'
require 'asciidoctor/latex/tex_preprocessor'
require 'asciidoctor/latex/tex_postprocessor'

$VERBOSE = true

module Asciidoctor
  module Latex

    class LatexEscape < Asciidoctor::Extensions::Preprocessor 
      def process document, reader
        return reader if reader.eof?
        replacement_lines = reader.read_lines.map do |line|
          #line = line.gsub('{', 'LATEXOPENBRACE')                #    "\\\\{")
          #line = line.gsub('}', 'LATEXCLOSEBRACE')               #    "\\\\}")
          #line = line.gsub("&", 'LATEXAMPERSAND')                #    "\\\\&")
          #line = line.gsub("#", 'LATEXSHARP')                    #    "\\\\#")
          #line = line.gsub("%", 'LATEXPERCENT')                  #    "\\%")
          #line = line.gsub("$", 'LATEXDOLLAR')                   #    "\\$")
          #line = line.gsub("_", 'LATEXUNDERSCORE')               #    "\\_")
          #line = line.gsub("|", 'LATEXVERTICALPIPE')             #    "\\textbar{}")
          #line = line.gsub("~", 'LATEXTILDE')                    #    "\\textasciitilde{}")
          #line = line.gsub("^", 'LATEXCIRCONFLEXE')              #    "\\textasciicircum{}")
          line
        end
        reader.unshift_lines replacement_lines
        reader
      end
    end

    class LatexUnescape < Asciidoctor::Extensions::Postprocessor 
      def process document, output
        # When writing latex commands in the target document,
        # I use some improbable UNICODE chars for curly and square braces
        # And just before giving back the converted document I convert it 
        # to the right LaTeX characters
        output = output.gsub('《', "{")
        output = output.gsub('》', "}")
        output = output.gsub('〈', "[")
        output = output.gsub('〉', "]")
      end
    end

    class Converter
      include Asciidoctor::Converter
      include Process
      register_for 'latex'

      # puts "HOLA!".red

      Asciidoctor::Extensions.register do
        postprocessor EntToUni if document.basebackend? 'tex' unless document.attributes['unicode'] == 'no'
        preprocessor  LatexEscape
        postprocessor LatexUnescape

      end

      def initialize backend, opts
        super
        basebackend    'tex'
        outfilesuffix '.tex'
      end

      def convert node, transform = nil

        case node.node_name
          # Block ------------------------------------------------------
          when 'document';            Process.document(node)
          when 'section';             Process.section(node)
          when 'paragraph';           Process.paragraph(node)
          when 'ulist';               Process.ulist(node)
          when 'olist';               Process.olist(node)
          when 'dlist';               Process.dlist(node)
          when 'page_break';          Process.pageBreak(node)
          when 'admonition';          Process.admonition(node)
          when 'stem';                Process.stem(node)
          when 'image';               Process.blockImage(node)
          when 'listing';             Process.listing(node)
          when 'literal';             Process.literal(node)
          when 'pass';                Process.pass(node)
          when 'quote';               Process.quote(node)
          when 'verse';               Process.verse(node)
          when 'floating_title';      Process.floatingTitle(node)

          # TODO : refactor
          when 'open';                node.tex_process  # 
          when 'example';             node.tex_process  # 
          when 'preamble';            node.tex_process  # 
          when 'sidebar';             node.tex_process  # 
          when 'toc';                 node.tex_process  # 
          when 'table';               node.tex_process  # 
          when 'thematic_break';      warn "#{node.node_name} is not implemented"
          when 'colist';              warn "#{node.node_name} is not implemented"
          when 'embedded';            warn "#{node.node_name} is not implemented"
          when 'video';               warn "#{node.node_name} is not implemented"
          when 'audio';               warn "#{node.node_name} is not implemented"

          # Inline -----------------------------------------------------
          when 'inline_quoted';       Process.inlineQuoted(node)
          when 'inline_image';        Process.inlineImage(node)
          when 'inline_anchor';       Process.inlineAnchor(node)
          when 'inline_break';        Process.inlineBreak(node)
          when 'inline_footnote';     Process.inlineFootNote(node)
          when 'inline_indexterm';    Process.inlineIndexTerm(node)
          when 'inline_button';       Process.inlineButton(node)
          when 'inline_kbd';          Process.inlineKeyboard(node)
          when 'inline_menu';         Process.inlineMenu(node)
          when 'inline_callout';      warn "#{node.node_name} is not implemented"

          else
            warn %(Node to implement: #{node.node_name}, class = #{node.class}).magenta #if $VERBOSE
        end
      end
    end # class Converter
  end # module Latex
end # module Asciidoctor
