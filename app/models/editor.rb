class Editor < ActiveRecord::Base
  self.table_name = 'users'
  self.primary_key = 'id'

  has_many :urs, class_name: 'UR', foreign_key: 'resolved_by'
  has_many :mps, class_name: 'MP', foreign_key: 'resolved_by'
end
