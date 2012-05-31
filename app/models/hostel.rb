class Hostel < ActiveRecord::Base

	has_many :students
	
	validates_presence_of :house

end
