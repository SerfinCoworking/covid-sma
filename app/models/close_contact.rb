class CloseContact < ApplicationRecord
  belongs_to :patient
  belongs_to :epidemic_sheet
  belongs_to :contact_type

  validates_presence_of :full_name, :contact_type_id, :patient, 
    :epidemic_sheet, :epidemic_sheet

  before_validation :assign_patient

  private
  
  def assign_patient
    self.patient = self.epidemic_sheet.patient
  end
end
