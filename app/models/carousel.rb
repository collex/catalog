class Carousel < ActiveRecord::Base
  has_and_belongs_to_many :archives
  has_many :federation

end
