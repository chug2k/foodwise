class CreateTokens < ActiveRecord::Migration
  def change
    create_table :tokens do |t|
      t.references :user
      t.datetime :expires_at
      t.string :token
      t.timestamps
    end

    add_index :tokens, :token, unique: true
  end
end
