class AddUniqueIndexToTripUsers < ActiveRecord::Migration[7.1]
  def change
    add_index :trip_users, [:user_id, :trip_id], unique: true
  end
end
