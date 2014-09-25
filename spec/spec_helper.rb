require 'rubygems'
require 'bundler'
require 'support/matchers/have_html'
require_relative '../orm-atlas-workers/workers/helpers/passthrough_helper.rb'

ENV['RACK_ENV'] ||= 'test'
Bundler.require(:test)

RSpec.configure do |config|
  config.color = true
  config.order = :random
end

def convert(asciidoc)
  asciidoc = unindent(asciidoc)
  str = Asciidoctor.render(asciidoc, safe: :safe, in_place: true, template_dir: htmlbook_path)
  Nokogiri::HTML(str)
end

def htmlbook_path
  "#{File.dirname(__FILE__)}/../htmlbook"
end

def convert_indexterm_tests
  indexterm_test_path = File.readlines("#{File.dirname(__FILE__)}/files/indexterm_testing.asciidoc")
  doc = Asciidoctor::Document.new(indexterm_test_path, template_dir: htmlbook_path)
  Nokogiri::HTML(doc.render)
end

def convert_passthrough_tests
  passthrough_test_path = File.readlines("#{File.dirname(__FILE__)}/files/passthrough_testing.asciidoc")
  doc = Asciidoctor::Document.new(passthrough_test_path, template_dir: htmlbook_path)
  Nokogiri::HTML(doc.render)
end

# Returns a copy of str with least common count of leading whitespaces removed.
def unindent(str)
  min_indent = str.lines.map { |line|
    line.index(/[^\s]/)
  }.compact.min

  str.lines.map { |line|
    line[min_indent..-1] || "\n"
  }.join('')
end
