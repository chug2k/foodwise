class CreateProducts < ActiveRecord::Migration
  create_table :products do |t|
    t.string :name
    t.float :grams_total
    t.float :serving_size
    t.float :grams_per_serving
    t.float :calories
    t.float :calories_from_fat
    t.float :total_fat
    t.float :saturated_fat
    t.float :trans_fat
    t.float :cholesterol
    t.float :sodium
    t.float :total_carb
    t.float :dietary_fiber
    t.float :sugar
    t.float :protein
    t.float :vitamin_a
    t.float :vitamin_c
    t.float :calcium
    t.float :vitamin_d
    t.float :phosphorus
    t.boolean :kosher
    t.boolean :gluten_free

    t.timestamps
  end
end