class PreviousSymptom < ApplicationRecord
  has_many :sheet_previous_symptoms
  has_many :epidemic_sheets, through: :sheet_previous_symptoms

  validates_presence_of :name
end
