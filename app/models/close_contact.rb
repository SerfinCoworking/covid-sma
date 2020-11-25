class CloseContact < ApplicationRecord
  belongs_to :patient
  belongs_to :epidemic_sheet
  belongs_to :contact_type
end
