class CaseStatus < ApplicationRecord
  has_many :case_definitions
  has_many :case_evolutions
  has_many :epidemic_sheets, through: :case_definitions

  validates_presence_of :name, :badge
end
