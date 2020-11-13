class EpidemicSheet < ApplicationRecord
  enum clinic_location: { sospechoso: 0, confirmado: 1 }

  belongs_to :patient
  belongs_to :case_definition
  belongs_to :created_by, class_name: 'User'
  belongs_to :establishment

  before_create :assign_establishment

  validates_presence_of :patient, :case_definition, :init_symptom_date, :epidemic_week
  validates :epidemic_week, numericality: { only_integer: true, greater_than: 0}
  validates_presence_of :establishment, if: Proc.new { |sheet| sheet.created_by.present? }

  accepts_nested_attributes_for :case_definition, allow_destroy: true
  
  private

  def assign_establishment
    if self.created_by.present?
      self.establishment = self.created_by.establishment
    end
  end
end
