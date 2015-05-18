class Person < ActiveRecord::Base
  
  
  validates_inclusion_of :sex, :in => %w{m f}
  
end
