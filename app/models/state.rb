class State < ActiveRecord::Base

  has_many :cities, foreign_key: 'state_id', class_name: 'City'
  has_many :urs, through: :cities
  has_many :mps, through: :cities
  has_many :pus, through: :cities
end
