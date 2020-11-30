class EpidemicSheet < ApplicationRecord
  include PgSearch
  enum clinic_location: { ambulatorio: 0, internado: 1 }

  # Relations
  belongs_to :patient
  belongs_to :case_definition, dependent: :destroy
  belongs_to :created_by, class_name: 'User'
  belongs_to :establishment
  has_many :close_contacts
  has_many :movements, class_name: "EpidemicSheetMovement"
  has_many :sheet_symptoms
  has_many :symptoms, through: :sheet_symptoms
  has_many :sheet_previous_symptoms
  has_many :previous_symptoms, through: :sheet_previous_symptoms

  accepts_nested_attributes_for :case_definition, allow_destroy: true
  accepts_nested_attributes_for :sheet_symptoms, allow_destroy: true
  accepts_nested_attributes_for :sheet_previous_symptoms, allow_destroy: true
  accepts_nested_attributes_for :patient
  accepts_nested_attributes_for :close_contacts

  # Validations
  validates_presence_of  :case_definition, :init_symptom_date, :epidemic_week
  validates :epidemic_week, numericality: { only_integer: true, greater_than: 0 }
  validates_presence_of :establishment, if: Proc.new { |sheet| sheet.created_by.present? }
  validates_presence_of :patient
  validates_associated :close_contacts, message: 'Por favor revise los campos de contacto con otras personas'
  
  # Delegations
  delegate :fullname, :dni, :last_name, :first_name, :age_string, :sex, to: :patient, prefix: true
  delegate :case_status_name, :case_status_badge, to: :case_definition, prefix: true
  
  # Callbacks
  before_create :assign_establishment
  before_validation :assign_epidemic_week
  
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

  
  def update_or_create_address(params)
    # Debemos mapear los valores "string" que vienen de andes
    @country = Country.where(name: params[:patient_attributes][:address_attributes][:country]).first_or_create(name: params[:patient_attributes][:address_attributes][:country])
    @state = State.where(name: params[:patient_attributes][:address_attributes][:state]).first_or_create(name: params[:patient_attributes][:address_attributes][:state], country_id: @country.id)
    @city = City.where(name: params[:patient_attributes][:address_attributes][:city]).first_or_create(name: params[:patient_attributes][:address_attributes][:city], state_id: @state.id )

    # Debemos actualizar o crear una nueva direccion
    @address = Address.where(id: self.patient.address_id).first

    if @address.present?
      @address.country = @country
      @address.state = @state
      @address.city = @city
      @address.line = params[:patient_attributes][:address_attributes][:line]
      @address.latitude = params[:patient_attributes][:address_attributes][:latitude]
      @address.longitude = params[:patient_attributes][:address_attributes][:longitude]
      @address.postal_code = params[:patient_attributes][:address_attributes][:postal_code]
      @address.save!
    else
      @address = Address.create(
        country: @country,
        state: @state,
        city: @city,
        line: params[:patient_attributes][:address_attributes][:line],
        latitude: params[:patient_attributes][:address_attributes][:latitude],
        longitude: params[:patient_attributes][:address_attributes][:longitude],
        postal_code: params[:patient_attributes][:address_attributes][:postal_code]
      )
      self.patient.address_id = @address.id
    end
      
  end

  def self.current_day
    where("created_at >= :today", { today: DateTime.now.beginning_of_day })
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
  # def reject_close_contacts(attributes)
  #   attributes['full_name'].blank?
  # end

  def assign_establishment
    if self.created_by.present?
      self.establishment = self.created_by.establishment
    end
  end

  def assign_epidemic_week
    self.epidemic_week = self.init_symptom_date.cweek
  end
end
