class CreateArchives < ActiveRecord::Migration
  def self.up
    create_table :archives do |t|
		t.string :typ
		t.integer :parent_id
		t.string :handle
		t.string :name
		t.string :site_url
		t.string :thumbnail
		t.integer :carousel_include
		t.text :carousel_description
		t.string :carousel_image_file_name
		t.string :carousel_image_content_type
		t.integer :carousel_image_file_size
		t.datetime :carousel_image_updated_at

      t.timestamps
    end
  end

  def self.down
    drop_table :archives
  end
end
