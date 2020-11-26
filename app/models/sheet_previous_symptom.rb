class SheetPreviousSymptom < ApplicationRecord
  belongs_to :epidemic_sheet
  belongs_to :previous_symptom
end
