class EpidemicSheetMovement < ApplicationRecord
  belongs_to :epidemic_sheet
  belongs_to :user
  belongs_to :sector
end
