class CreateCarousels < ActiveRecord::Migration
  def change
    create_table :carousels do |t|
      t.string :name

      t.timestamps
    end

    create_table :archives_carousels, :id => false do |t|
      t.integer :carousel_id
      t.integer :archive_id
    end
  end
end
