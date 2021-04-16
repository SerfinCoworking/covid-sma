class City < ApplicationRecord
  belongs_to :state
  belongs_to :department, optional: true
  has_many :establishments
  has_many :epidemic_sheets, through: :establishments

  validates_presence_of :name
end
