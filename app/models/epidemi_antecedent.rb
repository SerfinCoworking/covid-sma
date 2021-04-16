class EpidemiAntecedent < ApplicationRecord
  has_many :sheet_epidemi_antecedents
  has_many :epidemic_sheets, through: :sheet_epidemi_antecedents

  validates_presence_of :name
end
