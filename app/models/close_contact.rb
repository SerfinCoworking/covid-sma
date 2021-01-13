class CloseContact < ApplicationRecord
  belongs_to :patient
  belongs_to :epidemic_sheet, counter_cache: true
  belongs_to :contact_type, optional: true
  belongs_to :contact, class_name: 'Patient', optional: true

  validates_presence_of :full_name, :patient, :epidemic_sheet, :epidemic_sheet

  before_validation :assign_patient

  delegate :name, to: :contact_type, prefix: true

  private
  
  def assign_patient
    self.patient = self.epidemic_sheet.patient
  end
end
