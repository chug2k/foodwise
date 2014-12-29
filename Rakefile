# Rakefile
require 'rubygems'
require 'bundler'

Bundler.require

require './api/foodwise_api.rb'
require './models/user.rb'
require './models/product.rb'
require 'sinatra/activerecord/rake'


task :create_fake_user do
  response = HTTParty.get('http://api.randomuser.me')
  rando = JSON.parse(response.body)['results'].first['user']


  u = Foodwise::User.create(
      first_name: rando['name']['first'].capitalize,
      last_name: rando['name']['last'].capitalize,
      email: rando['email'],
      password: rando['password'],
      picture_url: rando['picture']['medium']
  )

  puts "Created user: #{u.first_name} #{u.last_name}, #{u.email}: password is #{rando['password']}."
end


task :create_fake_product do
  gf = rand < 0.5
  kosh = rand < 0.5

  p = Foodwise::Product.create(
      name: Faker::Commerce.product_name,
      grams_total: Faker::Commerce.price,
      serving_size: Faker::Commerce.price,
      grams_per_serving: Faker::Commerce.price,
      calories: Faker::Commerce.price,
      calories_from_fat: Faker::Commerce.price,
      total_fat: Faker::Commerce.price,
      saturated_fat: Faker::Commerce.price,
      trans_fat: Faker::Commerce.price,
      cholesterol: Faker::Commerce.price,
      sodium: Faker::Commerce.price,
      total_carb: Faker::Commerce.price,
      dietary_fiber: Faker::Commerce.price,
      sugar: Faker::Commerce.price,
      protein: Faker::Commerce.price,
      vitamin_a: Faker::Commerce.price,
      vitamin_c: Faker::Commerce.price,
      calcium: Faker::Commerce.price,
      vitamin_d: Faker::Commerce.price,
      phosphorus: Faker::Commerce.price,
      kosher: kosh,
      gluten_free: gf
  )
  puts "Created Product #{p.name} by #{Faker::Hacker.ingverb} my #{Faker::Hacker.adjective} #{Faker::Hacker.noun}."
end