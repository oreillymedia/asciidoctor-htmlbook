#!/usr/bin/env ruby

require 'asciidoctor'
require 'asciidoctor/extensions'
require 'libxml'
require 'libxslt'
require_relative 'constants.rb'

# Convert inline DocBook passthroughs to HTMLBook
class InlineDocBook2HTMLBookprocessor < Asciidoctor::Extensions::Preprocessor

  def process(reader, lines)
    return reader if lines.empty?
    lines = []
    while reader.has_more_lines?
      lines << reader.read_line
    end
    lines.each do |line|
      passfull = 'pass:\[(.*?)\]'
      regexmatch = line.scan(/#{passfull}/)
      regexmatch.each do |inlinearray|
        inlinearray.each do |inlinepass|
          convertedpass = convert_to_htmlbook(inlinepass.to_s)
          if convertedpass.empty?
            line.gsub!(/pass:\[#{Regexp.escape(inlinepass.to_s)}\]/, '')
          else
            convertedpass = convertedpass.gsub!(/\n\s?\s?/, '')
            line.gsub!(/#{Regexp.escape(inlinepass.to_s)}/, convertedpass.chomp)
          end
        end
      end
    end
    use_push_include = true
    if use_push_include
      reader.push_include lines, '<stdin>', '<stdin>'
      nil
    else
      Asciidoctor::Reader.new lines
    end
  end

end


# Convert block DocBook passthroughs to HTMLBook
class BlockDocBook2HTMLBookprocessor < Asciidoctor::Extensions::Treeprocessor

  def process
    process_blocks @document if @document.blocks?
  end
   
  def process_blocks(node)
    node.blocks.each_with_index do |block, i|
      if block.respond_to? :context
        if block.context == :pass
            block_text = convert_to_htmlbook(block.content)
            node.blocks[i] = Asciidoctor::Block.new @document, :pass, :content_model => :raw, :subs => [], :source => block_text
        else
          process_blocks block if block.blocks?
        end
      end
    end
  end

end


def convert_to_htmlbook(text)
  db2htmlbook = LibXML::XML::Document.file('/usr/local/app/docbook2htmlbook/db2htmlbook.xsl')
  xslt = LibXSLT::XSLT::Stylesheet.new(db2htmlbook)

  unless text.gsub(/\<\?(.*?)\?\>/, '').empty?
    if text =~ (/\<\?(.*?)\?\>/)
      puts "Warning! The processing instruction in '#{text}' will be dropped."
      text = text.gsub(/\<\?(.*?)\?\>/, '')
    end

    if text.include?('<')
      passthrough = LibXML::XML::Parser.string(text, :options => LibXML::XML::Parser::Options::RECOVER).parse
      # if and only if passthrough contains docbook content, apply xslt
      DOCBOOK_ELEMENTS.each { |d|
        if passthrough.find_first(d)
          result = xslt.apply(passthrough)
          result = result.to_s.gsub(/\<\?xml version="1.0" encoding="UTF-8"\?\>\n/, '')
          return result
        end
        }
      else
        puts "Warning! Passthrough content '#{text}' is not tagged. Passing through as is."
        return text
    end
  end

  # otherwise assume html and return string
  return passthrough.to_s.gsub(/\<\?xml version="1.0" encoding="UTF-8"\?\>\n/, '')
end


Asciidoctor::Extensions.register do |document|
  treeprocessor BlockDocBook2HTMLBookprocessor
  preprocessor InlineDocBook2HTMLBookprocessor
end

Dir.glob("*.asc*") do |filename|
    # For use on consolidated book file
    if filename == "book.asciidoc" || filename == "book.asc"
      Asciidoctor.render_file(filename, :safe => :safe, :in_place => true, :template_dir => "/usr/local/app/asciidoctor-htmlbook/htmlbook-autogen")
    # For use on chunked files
    else
      Asciidoctor.render_file(filename, :safe => :safe, :in_place => true, :template_dir => "/usr/local/app/asciidoctor-htmlbook/htmlbook")
    end
end
