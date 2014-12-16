require 'rubygems'
require 'bundler'

Bundler.require

require './foodwise_api.rb'

run Rack::URLMap.new('/api' => FoodwiseAPI.new)