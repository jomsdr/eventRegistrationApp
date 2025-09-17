require 'csv'

class EventRegistration < ApplicationRecord
  belongs_to :event
  belongs_to :user

  def self.to_csv
    attributes = %w{id event_id user_id created_at}

    ::CSV.generate(headers: true) do |csv|
      csv << attributes
      all.find_each do |registration|
        csv << attributes.map { |attr| registration.send(attr) }
      end
    end
  end

  validates :user_id, uniqueness: { scope: :event_id, message: "has already joined this event" }
end