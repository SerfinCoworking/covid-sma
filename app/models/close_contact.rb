class CloseContact < ApplicationRecord
  belongs_to :patient
  belongs_to :epidemic_sheet, counter_cache: true
  belongs_to :contact_type, optional: true
  belongs_to :contact, class_name: 'Patient', optional: true

  validates_presence_of :full_name, :patient, :epidemic_sheet, :epidemic_sheet
  validates_date :last_contact_date, on_or_before: :today, after: lambda { Date.new(2020, 3, 3) }, allow_blank: true

  before_validation :assign_patient

  delegate :name, to: :contact_type, prefix: true
  delegate :fullname, :dni, :patient_phones, :address_string, :address, to: :contact, prefix: true


  private
  
  def assign_patient
    self.patient = self.epidemic_sheet.patient
  end
end
