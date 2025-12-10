class AddCategoryToSpots < ActiveRecord::Migration[7.1]
  def change
    add_column :spots, :category, :integer
  end
end
