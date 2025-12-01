class AddTravelTimeToSpots < ActiveRecord::Migration[7.1]
  def change
    add_column :spots, :travel_time, :integer
  end
end
