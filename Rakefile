# Rakefile
require 'rubygems'
require 'bundler'

Bundler.require

require './api/foodwise_api.rb'
require './models/user.rb'
require './models/product.rb'
require 'sinatra/activerecord/rake'

require './lib/nutritionix_api.rb'


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

task :import_nutritionix, [:id] do |t, args|
  def get_nutrient(res, name)
    nutrients = res[:label][:nutrients]
    nutrient = nutrients.select{|x| x[:name] == name}.first
    nutrient.nil? ? 0.0 : nutrient[:value].try(:to_f) || 0.0
  end

  def get_total_grams(res)
    begin
      return res[:label][:serving][:metric][:qty]
    rescue
      null
    end
  end

  def create_product(id)
    puts "Contacting Nutritionix..."
    res = Foodwise::NutritionixAPI.new.item(id)
    puts "Received data about #{res[:name]}."
    if Foodwise::Product.where(name: res[:name], brand: res[:brand][:name]).count > 0
      puts "Skipping, #{res[:name]} by #{res[:brand][:name]} already in DB."
      return
    end


    #TODO: The calories from fat isn't returned by the API yet.
    prod = Foodwise::Product.create(
        name: res[:name],
        brand: res[:brand][:name],
        calories: get_nutrient(res, 'Calories'),
        grams_total: get_total_grams(res),
        calories_from_fat: get_nutrient(res, 'Total Fat') * 9.0,
        total_fat: get_nutrient(res, 'Total Fat'),
        saturated_fat: get_nutrient(res, 'Saturated Fat'),
        trans_fat: get_nutrient(res, 'Trans Fat'),
        cholesterol: get_nutrient(res, 'Cholesterol'),
        sodium: get_nutrient(res, 'Sodium'),
        total_carb: get_nutrient(res, 'Total Carbohydrate'),
        dietary_fiber: get_nutrient(res, 'Dietary Fiber'),
        sugar: get_nutrient(res, 'Sugars'),
        protein: get_nutrient(res, 'Protein'),
        vitamin_a: get_nutrient(res, 'Vitamin A %'),
        vitamin_c: get_nutrient(res, 'Vitamin C %'),
        calcium: get_nutrient(res, 'Calcium %'),
        vitamin_d: get_nutrient(res, 'Vitamin D %'),
        phosphorus: get_nutrient(res, 'Phosphorus'),

        front_image_full_url: res[:images][:front][:full],
        front_image_thumb_url: res[:images][:front][:thumb],
        label_image_full_url: res[:images][:label][:full]
    )

    if prod.persisted?
      puts "#{prod.name} successfully saved."
    else
      puts "Something went wrong: #{prod.errors}"
    end
  end

  create_product(args[:id])
  if args.extras.any?
    args.extras.each do |arg|
      create_product(arg)
    end
  end

end
