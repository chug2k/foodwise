# Rakefile
require 'rubygems'
require 'bundler'

Bundler.require

require './api/foodwise_api.rb'
require './models/user.rb'
require './models/product.rb'
require './models/category.rb'
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
    if name == 'Total Carbohydrate'
      name = 'Total Carbohydate' # Error in their API.
    end
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


task :import_excel do |t, args|
  def translate_category_name(excel_name)
    return nil if excel_name.nil?
    excel_name = excel_name.strip.downcase.
        gsub('vit ', 'vitamin ').gsub('carbohydrates', 'carb').gsub('saturated', 'saturated fat').
        gsub('brand type', 'name').
        gsub(' ', '_').
        underscore
    if Foodwise::Product.column_names.include?(excel_name)
      return excel_name
    end
    nil
  end

  def translate_value(val)
    return nil if val.nil?
    val.strip!
    # "calories"=>"Calories 340", "calories_from_fat"=>"Calories from Fat 260", "total_fat"=>"Total Fat 29 g45%", "saturated_fat"=>"Saturated Fat 7 g34%", "trans_fat"=>"Trans Fat 0 g", "cholesterol"=>"Cholesterol 60 mg19%", "sodium"=>"Sodium 890 mg37%", "total_carb"=>"Total Carbohydrate 13 g4%", "dietary_fiber"=>"Dietary Fiber 0 g1%", "sugar"=>"Sugars † 10 g", "protein"=>"Protein 8 g", "vitamin_a"=>"Vitamin A2%", "vitamin_c"=>"Vitamin C2%", "calcium"=>"Calcium0%", "phosphorus"=>"Phosphorus—", "vitamin_d"=>"Vitamin D—"}
    # Get the percentage-based values first.
    pct_match = val.match(/((Calcium)|(Vitamin A)|(Vitamin C)|(Phosphorus)|(Vitamin D))(\d%|—)/)
    if pct_match
      return pct_match.to_a.last.gsub('%', '').to_f
    end
    val.gsub!(/\d+%/, '') # Forget about percentages now.
    val.match(/\d+/).to_a.first.to_f
  end

  puts 'Opening file...'
  worksheet = Creek::Book.new 'data/yogurt-data.xlsx'
  successful_count = 0
  failed = []
  skipped = []
  sheets = worksheet.sheets
  sheets.each_with_index do |sheet, sheet_num|
    headers = {}
    category = Foodwise::Category.where(name: sheet.name).first_or_create
    sheet.rows.each_with_index do |row, i|
      if i == 0
        headers = row.values
      else
        prod_hash = {}
        row.each_with_index do |val, idx|
          prod_hash[:row_idx] = i + 1 # TOOD(Charles): Oops, got confused with i and idx. Fix this perhaps.
          category_name = translate_category_name(headers[idx])
          next if category_name.nil?
          if ['brand', 'name', 'serving_size'].include?(category_name)
            prod_hash[category_name] = val.last.try(:strip)
          else
            prod_hash[category_name] = translate_value(val.last)
          end
        end
        p = Foodwise::Product.new(prod_hash.except(:row_idx))
        p.category = category
        if p.save
          print '.'
          successful_count += 1
        else
          if p.errors.full_messages.first == 'Name has already been taken'
            skipped << "#{sheet_num}: #{prod_hash[:row_idx]}"
            print '.'
          else
            puts "Error: #{p.brand}: #{p.name}"
            skipped << "#{sheet_num}: #{prod_hash[:row_idx]}"
            print '!'
          end
        end
      end

    end
  end
  puts "\nSuccessfully added #{successful_count} products."
  puts "Failed on #{failed.count} products: #{failed}"
  puts "Skipped #{skipped.count} possibly duplicated products: #{skipped}"

end

