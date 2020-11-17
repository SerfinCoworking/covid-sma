class EpidemicSheet < ApplicationRecord
  include PgSearch
  enum clinic_location: { ambulatorio: 0, internado: 1 }

  belongs_to :patient
  belongs_to :case_definition
  belongs_to :created_by, class_name: 'User'
  belongs_to :establishment

  before_create :assign_establishment

  validates_presence_of  :case_definition, :init_symptom_date, :epidemic_week
  validates :epidemic_week, numericality: { only_integer: true, greater_than: 0}
  validates_presence_of :establishment, if: Proc.new { |sheet| sheet.created_by.present? }
  validates_presence_of :patient

  accepts_nested_attributes_for :case_definition, allow_destroy: true
  accepts_nested_attributes_for :patient

  delegate :fullname, :dni, :last_name, :first_name, :age_string, :sex, to: :patient, prefix: true
  delegate :case_type, to: :case_definition, prefix: true
  
  filterrific(
    available_filters: [
      :search_fullname,
      :search_dni,
      :case_type
    ]
  )

  pg_search_scope :search_dni,
    :associated_against => { patient: [:dni] },
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_fullname,
    :associated_against => { patient: [ :first_name, :last_name ]},
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.  

  private

  def assign_establishment
    if self.created_by.present?
      self.establishment = self.created_by.establishment
    end
  end
end
