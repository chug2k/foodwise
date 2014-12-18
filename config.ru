require 'rubygems'
require 'bundler'

Bundler.require

Dir['./models/*.rb'].each {|f| require f }
require './api/foodwise_api.rb'
require './admin/foodwise_admin.rb'


run Rack::URLMap.new('/api' => Foodwise::Api.new, '/admin' => Foodwise::Admin.new)

