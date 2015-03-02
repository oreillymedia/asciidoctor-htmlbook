#!/usr/bin/env ruby

require 'asciidoctor'
require 'asciidoctor/extensions'

Dir.glob("*.asc*") do |filename|
    # For use on consolidated book file
    if filename == "book.asciidoc" || filename == "book.asc"
      Asciidoctor.render_file(filename, :safe => :safe, :in_place => true, :doctype => 'book', :template_dir => "/vagrant/asciidoctor-htmlbook/htmlbook-autogen")
      # Asciidoctor.render_file(filename, :safe => :safe, :in_place => true, :doctype => 'book', :template_dir => "/usr/local/app/asciidoctor-htmlbook/htmlbook-autogen")
    # For use on chunked files
    else
      Asciidoctor.render_file(filename, :safe => :safe, :in_place => true, :doctype => 'book', :template_dir => "/vagrant/asciidoctor-htmlbook/htmlbook")
      # Asciidoctor.render_file(filename, :safe => :safe, :in_place => true, :doctype => 'book', :template_dir => "/usr/local/app/asciidoctor-htmlbook/htmlbook")
    end
end
