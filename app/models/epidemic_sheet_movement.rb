class EpidemicSheetMovement < ApplicationRecord
  # Relationships
  belongs_to :epidemic_sheet
  belongs_to :user
  belongs_to :sector

  # Delegations
  delegate :full_name, to: :user, prefix: true, allow_nil: true
end
