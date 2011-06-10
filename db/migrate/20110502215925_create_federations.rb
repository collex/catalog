class CreateFederations < ActiveRecord::Migration
  def self.up
    create_table :federations do |t|
		t.string :name
		t.string :thumbnail
		t.string :ip
		t.string :site

      t.timestamps
    end
  end

  def self.down
    drop_table :federations
  end
end
