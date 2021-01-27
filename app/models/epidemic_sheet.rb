class EpidemicSheet < ApplicationRecord
  include PgSearch
  enum clinic_location: { ambulatorio: 0, internado: 1 }

  # Relations
  belongs_to :patient
  belongs_to :case_definition, dependent: :destroy
  belongs_to :created_by, class_name: 'User'
  belongs_to :establishment
  has_one :city, through: :establishment
  has_one :case_status, through: :case_definition
  has_one :address, through: :patient
  has_one :current_address, through: :patient
  has_many :sub_contacts, class_name: 'EpidemicSheet', foreign_key: :parent_contact_id
  has_many :close_contacts
  has_many :movements, class_name: "EpidemicSheetMovement"
  has_many :sheet_symptoms
  has_many :symptoms, through: :sheet_symptoms
  has_many :sheet_previous_symptoms
  has_many :previous_symptoms, through: :sheet_previous_symptoms
  has_many :case_evolutions, dependent: :destroy

  accepts_nested_attributes_for :case_definition, allow_destroy: true
  accepts_nested_attributes_for :sheet_symptoms, allow_destroy: true
  accepts_nested_attributes_for :sheet_previous_symptoms, allow_destroy: true
  accepts_nested_attributes_for :patient
  accepts_nested_attributes_for :close_contacts,
    :allow_destroy => true

  # Validations
  validates_presence_of :case_definition, :epidemic_week
  validates_presence_of :init_symptom_date, if: Proc.new { |sheet| sheet.case_definition.needs_fis? }
  validate :symptoms_validate_presence?
  validate :fis_validate_presence?
  validates_presence_of :notification_date
  validates_presence_of :establishment, if: Proc.new { |sheet| sheet.created_by.present? }
  validates_presence_of :patient
  validates_associated :close_contacts, message: 'Por favor revise los campos de contacto con otras personas'
  validate :fis_date_cannot_be_in_the_future
  validate :notification_date_cannot_be_in_the_future


  # Delegations
  delegate :fullname, :dni, :last_name, :first_name, :age_string, :sex, 
    :assigned_establishment, :address_string, :current_address_get_full_address_name, to: :patient, prefix: true
  delegate :case_status_name, :case_status_badge, to: :case_definition, prefix: true
  delegate :case_status, to: :case_definition
  delegate :parent_contact, to: :patient, prefix: false
  
  # Callbacks
  before_create :assign_establishment
  after_validation :assign_epidemic_week, if: Proc.new { |sheet| sheet.init_symptom_date.present? }
  
  filterrific(
    default_filter_params: { sorted_by: 'notificacion_desc'},
    available_filters: [
      :sorted_by,
      :search_dni,
      :search_fullname,
      :by_case_statuses,
      :by_establishment,
      :by_clinic_location,
      :since_date_fis,
      :to_date_fis,
      :since_date,
      :to_date,
      :by_close_contact,
      :is_in_sisa
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^paciente_/
      # Ordenamiento por apellido de pacientes
      reorder("patients.last_name #{ direction }, epidemic_sheets.id").joins(:patient)
    when /^edad_/
      # Ordenamiento por fecha de nacimiento
      reorder("patients.birthdate #{ direction }, epidemic_sheets.id").joins(:patient)
    when /^caso_/
      # Ordenamiento por estado
      reorder("case_statuses.name #{ direction }, epidemic_sheets.id").joins(:case_status)
    when /^fis/
      # Ordenamiento por fecha de recepción
      reorder("epidemic_sheets.init_symptom_date #{ direction }, epidemic_sheets.id")
    when /^notificacion_/
      # Ordenamiento por fecha de recepción
      reorder("epidemic_sheets.notification_date #{ direction }, epidemic_sheets.id")
    when /^establecimiento_asignado_/
      # Ordenamiento por fecha de recepción
      reorder("establishments.name #{ direction }, epidemic_sheets.id").joins(:establishment)
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  pg_search_scope :search_dni,
    :associated_against => { patient: [:dni] },
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_fullname,
    :associated_against => { patient: [ :first_name, :last_name ]},
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :by_close_contact,
    :associated_against => { close_contacts: [ :dni, :full_name ]},
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  # scope :by_establishment, ->(ids_ary) { where(patients: {assigned_establishment_id: ids_ary} ).joins(:patient) }
  scope :by_case_statuses, ->(ids_ary) { joins(:case_definition).where(case_definitions: {case_status_id: ids_ary}) }
 
  # scope :by_establishment, ->(ids_ary) { where(patients: {assigned_establishment_id: ids_ary} ).joins(:patient) }

  scope :by_establishment, lambda {|ids_ary| 
    left_joins(:patient).where(patients: {assigned_establishment_id: ids_ary} ) 
  }

  scope :by_city, lambda {|ids_ary| 
    left_joins(:establishment).where(establishments: {city_id: ids_ary} )
  }

  scope :by_clinic_location, ->(ids_ary) { where(clinic_location: ids_ary) }

  scope :since_date_fis, lambda { |a_date|
    where('epidemic_sheets.init_symptom_date >= ?', a_date)
  }

  scope :to_date_fis, lambda { |a_date|
    where('epidemic_sheets.init_symptom_date <= ?', a_date)
  }

  scope :since_date, lambda { |a_date|
    where('epidemic_sheets.notification_date >= ?', a_date)
  }

  scope :to_date, lambda { |a_date|
    where('epidemic_sheets.notification_date <= ?', a_date)
  }

  scope :is_in_sisa, lambda { |a_boolean| where(is_in_sisa: a_boolean) }

  def self.options_for_sisa
    [
      ["Ambos", ""],
      ["Si", "true"],
      ["No", "false"]
    ]
  end
  
  def self.current_day
    where("epidemic_sheets.created_at >= :today_beginning AND epidemic_sheets.created_at <= :today_end", 
      { today_beginning: DateTime.now.beginning_of_day,
        today_end: DateTime.now.end_of_day
      }
    )
  end

  def self.last_week
    where("epidemic_sheets.created_at >= :last_week", { last_week: 1.weeks.ago.midnight })
  end

  def self.current_year
    where("epidemic_sheets.created_at >= :year", { year: DateTime.now.beginning_of_year })
  end

  def self.current_month
    where("epidemic_sheets.created_at >= :month", { month: DateTime.now.beginning_of_month })
  end

  def self.total_new_positives_to_city(a_city)
    return EpidemicSheet
      .by_city(a_city)
      .since_date(Date.yesterday)
      .to_date(Date.yesterday)
      .by_case_statuses(CaseStatus.find_by_name('Positivo')).count
  end

  def self.total_close_contacts_to_city(a_city)
    return EpidemicSheet
      .by_city(a_city)
      .by_case_statuses(CaseStatus.find_by_name('Positivo'))
      .sum(:close_contacts_count)
  end

  private
  def assign_establishment
    if self.created_by.present?
      self.establishment = self.created_by.establishment
    end
  end

  def assign_epidemic_week
    self.epidemic_week = self.init_symptom_date.cweek
  end

  def fis_date_cannot_be_in_the_future
    if init_symptom_date.present? && init_symptom_date > Date.today
      errors.add(:init_symptom_date_future, "El FIS no puede estar en días futuros")
    end
  end
  
  
  def notification_date_cannot_be_in_the_future
    if notification_date.present? && notification_date > Date.today
      errors.add(:notification_date_future, "La fecha de notificación no puede estar en días futuros")
    end
  end
  
  def symptoms_validate_presence?
    if self.init_symptom_date.present? && self.symptom_ids.nil?
      errors.add(:symptoms_presence, "Debe seleccionar almenos 1 síntoma")
    end
  end
  
  def fis_validate_presence?
    if self.presents_symptoms.present? && self.init_symptom_date.nil?
      errors.add(:fis_validate_presence, "Debe seleccionar fecha de inicio de síntomas")
    end
  end
end
