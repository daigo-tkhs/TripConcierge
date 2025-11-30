class Spot < ApplicationRecord
  belongs_to :trip
  before_create :set_default_position

  validates :name, presence: true

  geocoded_by :name
  after_validation :geocode, if: :will_save_change_to_name?

  private
  def set_default_position
    unless self.position.present?
      max_position = self.trip.spots.maximum(:position) || 0
      self.position = max_position + 1
    end
  end
end
