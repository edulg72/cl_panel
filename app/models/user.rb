class User < ActiveRecord::Base

  has_many :comments, class_name: 'UR', foreign_key: 'last_comment_by'
end
