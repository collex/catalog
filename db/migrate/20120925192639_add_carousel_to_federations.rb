class AddCarouselToFederations < ActiveRecord::Migration
  def change
    add_column :federations, :carousel_id, :integer
  end
end
