class CreateSafeCounters < ActiveRecord::Migration[8.0]
  def change
    create_table :safe_counters do |t|
      t.string :name
      t.bigint :count

      t.timestamps
    end
  end
end
