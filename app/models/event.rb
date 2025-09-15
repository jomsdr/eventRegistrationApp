class Event < ApplicationRecord
  belongs_to :creator, class_name: 'User', foreign_key: 'user_id'

  has_many :event_registrations, dependent: :destroy
  has_many :participants, through: :event_registrations, source: :user

  validates :title, :description, :date, presence: true
end
