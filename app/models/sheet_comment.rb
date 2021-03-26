class SheetComment < ApplicationRecord
  belongs_to :epidemic_sheet
  belongs_to :user
end
