
# Describes an eMOP work.
#
class Work < ActiveRecord::Base
   establish_connection(:emop)
   self.table_name = :works
   self.primary_key = :wks_work_id
   #has_many :pages, :foreign_key => :pg_work_id

   def isEEBO?
      if !self.wks_eebo_directory.nil? && self.wks_eebo_directory.length > 0
         return true
      end
      return false
   end
end