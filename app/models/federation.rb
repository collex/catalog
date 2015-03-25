class Federation < ActiveRecord::Base
   before_save :update_carousel

   belongs_to :carousel, :inverse_of => :federation
   has_attached_file :thumbnail,
                    :styles => { :thumb => "220x80>" },
                    :path => ":rails_root/public/system/:attachment/:id/:style/:filename",
                    :url => "/system/:attachment/:id/:style/:filename"
   validates_attachment_size :thumbnail, :less_than => 5.megabytes,  :unless => Proc.new {|m| m[:thumbnail].nil?}
   validates_attachment_content_type :thumbnail, :content_type => ['image/jpeg', 'image/png', 'image/gif'], :unless => Proc.new {|m| m[:thumbnail].nil?}

   def self.request_from_federation(ip)
      # If the ip is on the white list, it can be used.
      white_list = WhiteList.where(ip: ip)
      return true if white_list.length > 0

      # This checks to see if the ip address of the caller matches any of the
      # federations.
      fed = Federation.find_by({ ip: ip })
      #return false
      return fed != nil
   end

   private

   def update_carousel
      if self.carousel.nil?
         self.carousel = Carousel.new(:name => self.name)
      else
         self.carousel.name = self.name
         self.carousel.save
      end
   end

end
