class CreateFederations < ActiveRecord::Migration
  def self.up
    create_table :federations do |t|
      t.string :name

      t.timestamps
    end
  end

  def self.down
    drop_table :federations
  end
end
