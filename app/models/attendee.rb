class Attendee < ActiveRecord::Base
  belongs_to :user
  belongs_to :meetup

  validates :user_id, presence: true
  validates :meetup_id, presence: true
  validates :user_id, uniqueness: { scope: :meetup_id }
end
