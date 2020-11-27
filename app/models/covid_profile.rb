class CovidProfile < ApplicationRecord
  include PgSearch
  enum status: { sospechoso: 0, pendiente: 1, positivo: 2, negativo: 3, recuperado: 4, fallecido: 5 }
  enum clinic_location: { ambulatorio: 0, internado: 1 }

  belongs_to :patient
  belongs_to :epidemic_sheet
  has_many :movements, class_name: "CovidProfileMovement"

  delegate :dni, :last_name, :first_name, :age_string, :sex, :birthdate, :marital_status, :status, to: :patient, prefix: true
  delegate :patient_phones, to: :patient
  delegate :current_address, to: :patient

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
end
