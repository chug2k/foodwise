class CreateUsers < ActiveRecord::Migration
  def change
    create_table :users do |t|
      t.string :first_name
      t.string :last_name
      t.string :email
      t.string :password_hash
      t.boolean :is_admin
      t.string :picture_url
      t.timestamps
    end
  end
end
