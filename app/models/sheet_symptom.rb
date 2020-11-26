class SheetSymptom < ApplicationRecord
  belongs_to :epidemic_sheet
  belongs_to :symptom
end
