class CreateArchives < ActiveRecord::Migration
  def self.up
    create_table :archives do |t|
      t.string :name
      t.string :site_url
      t.string :thumbnail
      t.text :carousel_description
      t.string :carousel_image_url

      t.timestamps
    end
  end

  def self.down
    drop_table :archives
  end
end
