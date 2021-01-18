class City < ApplicationRecord
  belongs_to :state
  belongs_to :department, optional: true

  validates_presence_of :name
end
