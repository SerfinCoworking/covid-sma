class Symptom < ApplicationRecord
  has_many :sheet_symptoms
  has_many :epidemic_sheets, through: :sheet_symptoms

  validates_presence_of :name
end
