class CreateLinks < ActiveRecord::Migration[8.0]
  def change
    create_table :links do |t|
      t.text :original_link, limit: 80000
      t.string :short_link, limit: 9
      t.datetime :expiry_date
      t.timestamps
    end

    add_index :links, :short_link
  end
end
