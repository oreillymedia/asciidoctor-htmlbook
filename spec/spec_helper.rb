require 'rubygems'
require 'bundler'
require_relative '../orm-atlas-workers/workers/helpers/passthrough_helper.rb'

ENV["RACK_ENV"] ||= 'test'
Bundler.require(:test)

RSpec.configure do |config|
  config.color_enabled = true
  config.order = "random"
end

def convert(asciidoc)
  Asciidoctor.render(asciidoc, :safe => :safe, :in_place => true, :template_dir => htmlbook_path)
end

def htmlbook_path
  "#{File.dirname(__FILE__)}/../htmlbook"
end

def convert_indexterm_tests
  indexterm_test_path = File.readlines("#{File.dirname(__FILE__)}/files/indexterm_testing.asciidoc")
  doc = Asciidoctor::Document.new(indexterm_test_path, :template_dir => htmlbook_path)
  doc.render
end

def convert_passthrough_tests
  passthrough_test_path = File.readlines("#{File.dirname(__FILE__)}/files/passthrough_testing.asciidoc")
  doc = Asciidoctor::Document.new(passthrough_test_path, :template_dir => htmlbook_path)
  doc.render
end
