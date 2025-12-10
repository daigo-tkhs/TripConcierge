# frozen_string_literal: true

class AddPositionToSpots < ActiveRecord::Migration[7.1]
  def change
    add_column :spots, :position, :integer
  end
end
