class Federation < ActiveRecord::Base
  after_initialize :check_for_carousel
  belongs_to :carousel, :inverse_of => :federation
	has_attached_file :thumbnail,
                    :styles => { :thumb => "220x80>" },
                    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                    :url => "/system/:attachment/:id/:style/:filename"


	def self.request_from_federation(ip)
		# This checks to see if the ip address of the caller matches any of the federations.
		fed = Federation.find_by_ip(ip)
		#return false
		return fed != nil
  end

  private
    def check_for_carousel
      # This is here to make sure there are no federations w/out carousels after the db:migrate
      if self.carousel.nil?
        self.carousel = Carousel.new(:name => self.name)
        self.save()
      end
    end

end
