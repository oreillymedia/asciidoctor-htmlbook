require 'rubygems'
require 'bundler'

ENV["RACK_ENV"] ||= 'test'
Bundler.require(:test)

RSpec.configure do |config|
  config.color_enabled = true
  config.order = "random"
end