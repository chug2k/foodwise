class CreateProducts < ActiveRecord::Migration
  def change
    create_table :products do |t|
      t.string :name
      t.string :brand
      t.references :category
      t.float :grams_total
      t.string :serving_size
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

      t.string :front_image_full_url
      t.string :front_image_thumb_url
      t.string :label_image_full_url

      t.boolean :kosher
      t.boolean :gluten_free

      t.timestamps
    end
  end

end
