class Meetup < ActiveRecord::Base
  has_many :users, through: :attendees
  belongs_to :creator, class_name: 'User', foreign_key: :creator_id

  validates_presence_of :name, :location, :creator_id, :description
end
