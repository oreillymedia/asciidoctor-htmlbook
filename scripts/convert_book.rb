# This script runs through a book folder and converts all asciidoc files to htmlbook files
require 'rubygems'
require 'asciidoctor'
require 'fileutils'

book_folder = ARGV[0]
raise "Book Folder does not exist: #{book_folder}" unless File.exist?(book_folder)

Dir.glob("#{book_folder}**/*.{asciidoc,adoc,asc}") do |file|
  puts "Converting #{File.basename(file)}"
  asciidoc  = File.open(file).read
  html      = Asciidoctor.convert(asciidoc, :template_dir => "#{File.dirname(__FILE__)}/../htmlbook", :attributes => {'compat-mode' => 'true'})
  filename  = "#{File.dirname(file)}/#{File.basename(file,'.*')}.html"
  File.open(filename, 'w') { |file| file.write(html) }
end