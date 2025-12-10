# frozen_string_literal: true

class ChecklistItem < ApplicationRecord
  belongs_to :trip

  validates :name, presence: true
end
