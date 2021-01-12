class EpidemicSheet < ApplicationRecord
  include PgSearch
  enum clinic_location: { ambulatorio: 0, internado: 1 }

  # Relations
  belongs_to :patient
  belongs_to :case_definition, dependent: :destroy
  belongs_to :created_by, class_name: 'User'
  belongs_to :establishment
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
  accepts_nested_attributes_for :close_contacts

  # Validations
  validates_presence_of  :case_definition, :epidemic_week
  validates_presence_of :init_symptom_date, if: Proc.new { |sheet| sheet.case_definition.needs_fis? }
  validates_presence_of :notification_date
  validates_presence_of :establishment, if: Proc.new { |sheet| sheet.created_by.present? }
  validates_presence_of :patient
  validates_associated :close_contacts, message: 'Por favor revise los campos de contacto con otras personas'
  
  # Delegations
  delegate :fullname, :dni, :last_name, :first_name, :age_string, :sex, 
    :assigned_establishment, to: :patient, prefix: true
  delegate :case_status_name, :case_status_badge, to: :case_definition, prefix: true
  delegate :case_status, to: :case_definition
  delegate :parent_contact, to: :patient, prefix: false
  
  # Callbacks
  before_create :assign_establishment
  after_validation :assign_epidemic_week, if: Proc.new { |sheet| sheet.init_symptom_date.present? }
  
  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_dni,
      :search_fullname,
      :by_case_statuses,
      :by_establishment,
      :since_date_fis,
      :to_date_fis,
      :since_date,
      :to_date,
      :by_close_contact
    ]
  )

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/
      # Ordenamiento por fecha de recepción
      order("epidemic_sheets.created_at #{ direction }")
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

  scope :by_case_statuses, ->(ids_ary) { joins(:case_definition).where(case_definitions: {case_status_id: ids_ary}) }
 
  scope :by_establishment, ->(ids_ary) { joins(:patient).where(patients: {assigned_establishment_id: ids_ary}) }

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
  
  def self.current_day
    where("epidemic_sheets.created_at >= :today_beginning AND epidemic_sheets.created_at <= :today_end", 
      { today_beginning: DateTime.now.beginning_of_day,
        today_end: DateTime.now.end_of_day
      }
    )
  end

  def self.last_week
    where("created_at >= :last_week", { last_week: 1.weeks.ago.midnight })
  end

  def self.current_year
    where("created_at >= :year", { year: DateTime.now.beginning_of_year })
  end

  def self.current_month
    where("created_at >= :month", { month: DateTime.now.beginning_of_month })
  end

  private
  def needs_fis?
    self.close_contact.case_satus.needs_fis?
  end

  def assign_establishment
    if self.created_by.present?
      self.establishment = self.created_by.establishment
    end
  end

  def assign_epidemic_week
    self.epidemic_week = self.init_symptom_date.cweek
  end
end
