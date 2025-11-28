class AddEndDateToTrips < ActiveRecord::Migration[7.1]
  def change
    add_column :trips, :end_date, :date
  end
end
