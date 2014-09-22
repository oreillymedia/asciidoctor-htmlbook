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
          convertedpass = convert_to_htmlbook(inlinepass)
          if convertedpass.empty?
            line.gsub!(/pass:\[#{Regexp.escape(inlinepass)}\]/, '')
          else
            line.gsub!(/#{Regexp.escape(inlinepass)}/, convertedpass.sub(/\n/, '').strip)
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

  # Drop processing instructions
  text = text.gsub(/\<\?(.*?)\?\>/, '')

  # If passthrough contains docbook content, apply xslt
  if text.include?('<')
    wrapped = "<root>" + text + "</root>"
    passthrough = LibXML::XML::Parser.string(wrapped, :options => LibXML::XML::Parser::Options::RECOVER).parse
    DOCBOOK_ELEMENTS.each { |d|
      if passthrough.find_first('/root' + d)
        result = xslt.apply(passthrough)
        result = result.to_s.gsub(/\<\?xml version="1.0" encoding="UTF-8"\?\>\n/, '').gsub(/\<\/?root\>/, '')
        return result
      end
    }
  end

  # Otherwise assume html and return string
  return text
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
