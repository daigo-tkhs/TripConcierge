class Spot < ApplicationRecord
  belongs_to :trip
  validates :name, presence: true

  geocoded_by :name
  after_validation :geocode, if: :will_save_change_to_name?
end
