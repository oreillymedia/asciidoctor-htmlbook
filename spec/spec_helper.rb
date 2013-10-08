require 'rubygems'
require 'bundler'

ENV["RACK_ENV"] ||= 'test'
Bundler.require(:test)

RSpec.configure do |config|
  config.color_enabled = true
  config.order = "random"
end

def convert(asciidoc)
  Asciidoctor.render(asciidoc, :template_dir => htmlbook_path)
end

def htmlbook_path
  "#{File.dirname(__FILE__)}/../htmlbook"
end