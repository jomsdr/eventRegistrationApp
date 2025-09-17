class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :jwt_authenticatable,
         jwt_revocation_strategy: JwtDenylist


  # Role management
  enum :role, { user: "user", admin: "admin" }

  # Validations
  validates :role, presence: true, inclusion: { in: roles.keys }
  validates :name, presence: true, length: { maximum: 100 }

  # Associations

  # Events created by the user
  has_many :created_events, class_name: 'Event', foreign_key: 'user_id', dependent: :destroy

  # Events the user has joined 
  has_many :event_registrations, dependent: :destroy
  has_many :joined_events, through: :event_registrations, source: :event

end