class AddEmailToEventRegistrations < ActiveRecord::Migration[8.0]
  def change
    add_column :event_registrations, :email, :string
  end
end
