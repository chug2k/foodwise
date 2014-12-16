# Rakefile
require 'rubygems'
require 'bundler'

Bundler.require

require './foodwise_api.rb'
require 'sinatra/activerecord/rake'


task :create_fake_user do
  response = HTTParty.get('http://api.randomuser.me')
  rando = JSON.parse(response.body)['results'].first['user']


  u = User.create(
      first_name: rando['name']['first'].capitalize,
      last_name: rando['name']['last'].capitalize,
      email: rando['email'],
      password: rando['password'],
      picture_url: rando['picture']['medium']
  )

  puts "Created user: #{u.first_name} #{u.last_name}, #{u.email}: password is #{rando['password']}."

end