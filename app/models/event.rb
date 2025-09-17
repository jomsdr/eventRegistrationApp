class Event < ApplicationRecord
  belongs_to :creator, class_name: 'User', foreign_key: 'user_id'

  has_many :event_registrations, dependent: :destroy
  has_many :participants, through: :event_registrations, source: :user

  def self.to_csv
    attributes = %w{id title description date location}

    ::CSV.generate(headers: true) do |csv|
      csv << attributes

      all.find_each do |event|
        csv << attributes.map { |attr| event.send(attr) }
      end
    end
  end

  validates :title, :description, :date, :location, presence: true
end
