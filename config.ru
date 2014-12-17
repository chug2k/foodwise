require 'rubygems'
require 'bundler'

Bundler.require

require './models/user'
require './api/foodwise_api.rb'
require './admin/foodwise_admin.rb'


run Rack::URLMap.new('/api' => Foodwise::Api.new, '/admin' => Foodwise::Admin.new)

