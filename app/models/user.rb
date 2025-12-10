# frozen_string_literal: true

# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  validates :nickname, presence: true
  has_many :owned_trips, class_name: 'Trip', foreign_key: 'owner_id', dependent: :destroy, inverse_of: :owner
  has_many :trip_users, dependent: :destroy
  has_many :trips, through: :trip_users
  has_many :messages, dependent: :destroy
  has_many :favorites, dependent: :destroy
  has_many :favorite_trips, through: :favorites, source: :trip
end
