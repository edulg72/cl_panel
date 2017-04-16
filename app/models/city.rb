class City < ActiveRecord::Base

  belongs_to :state, foreign_key: 'state_id', class_name: 'State'
  has_many :urs, foreign_key: 'city_id', class_name: 'UR'
  has_many :mps, foreign_key: 'city_id', class_name: 'MP'
  has_many :pus, foreign_key: 'city_id', class_name: 'PU'
end
