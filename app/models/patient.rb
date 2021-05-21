class Patient < ApplicationRecord
  include PgSearch

  enum status: { Temporal: 0, Validado: 1 }
  enum sex: { Otro: 1, Femenino: 2, Masculino: 3 }
  enum marital_status: { Soltero: 1, Casado: 2, Separado: 3, Divorciado: 4, Viudo: 5, otro: 6 }

  # Relaciones
  has_one_base64_attached :avatar
  
  belongs_to :patient_type
  belongs_to :address, optional: true
  belongs_to :current_address, optional: true
  belongs_to :occupation, optional: true
  belongs_to :assigned_establishment, class_name: "Establishment"
  has_one :epidemic_sheet, dependent: :destroy
  has_many :patient_phones, dependent: :destroy
  has_many :case_evolutions
  has_many :close_contacts, dependent: :destroy

  belongs_to :parent_contact, class_name: 'Patient', optional: true
  has_many :child_contacts, class_name: 'Patient', foreign_key: :parent_contact_id, dependent: :destroy

  accepts_nested_attributes_for :patient_phones, :allow_destroy => true, reject_if: proc { |attributes| attributes['number'].blank? }
  accepts_nested_attributes_for :address
  accepts_nested_attributes_for :current_address

  # Validaciones
  validates_presence_of :first_name, :last_name, :dni
  validates_uniqueness_of :dni
  validate :not_be_the_same_parent_contact, if: Proc.new { |sheet| sheet.parent_contact_id.present? }

  # Delegaciones
  delegate :country_name, :string, :state_name, :city_name, :line, to: :address, prefix: :address
  delegate :name, to: :patient_type, prefix: :patient_type
  delegate :get_full_address_name, to: :current_address, prefix: :current_address

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :sorted_by,
      :search_fullname,
      :search_dni,
      :with_patient_type_id,
    ]
  )

  pg_search_scope :get_by_dni_and_fullname,
    against: [ :dni, :first_name, :last_name ],
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_fullname,
    against: [ :first_name, :last_name ],
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_lastname,
    against: [ :last_name ],
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_firstname,
    against: [ :first_name ],
    :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
    :ignoring => :accents # Ignorar tildes.

  scope :search_dni, lambda { |query|
    string = query.to_s
    where('dni::text LIKE ?', "%#{string}%")
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("patients.created_at #{ direction }")
    when /^nacimiento_/
      # Ordenamiento por fecha de creación en la BD
      reorder("patients.birthdate #{ direction }")
    when /^dni_/
      # Ordenamiento por fecha de creación en la BD
      reorder("patients.dni #{ direction }")
    when /^nombre_/
      # Ordenamiento por nombre de paciente
      reorder("LOWER(patients.first_name) #{ direction }")
    when /^apellido_/
      # Ordenamiento por apellido de paciente
      reorder("LOWER(patients.last_name) #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_patient_type_id, lambda { |a_patient_type|
    where('patients.patient_type_id = ?', a_patient_type)
  }

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
      ['Nombre (a-z)', 'nombre_asc'],
      ['Apellido (a-z)', 'apellido_asc'],
    ]
  end

  #Métodos públicos
  def full_info
    self.last_name+", "+self.first_name+" "+self.dni.to_s
  end

  def fullname
    self.last_name+", "+self.first_name
  end

  def age_string
    self.age.present? ? self.age.to_s+" años" : "---"
  end

  def age
    if self.birthdate.present?
      return ((Time.zone.now - self.birthdate.to_time) / 1.year.seconds).floor
    else
      return nil
    end
  end

  def phones_string
    phone_string = ""
    self.patient_phones.each do |phone|
      phone_string = phone_string + phone.phone_type+" "+phone.number+" "
    end
    return phone_string
  end

  def age_range
    case self.age 
    when 0..10
      '0-10'
    when 11..20
      '11-20'
    when 21..30
      '21-30'
    when 31..40
      '31-40'
    when 41..50
      '41-50'
    when 51..60
      '51-60'
    when 61..70
      '61-70'
    when 71..80
      '71-80'
    when 81..90
      '81-90'
    when 91..100
      '91-100'
    when 101..110
      '101-110'
    end
  end

  def not_be_the_same_parent_contact
    if self.parent_contact_id == self.id
      errors.add(:parent_contact_id, 'No puede ser contacto padre de sí mismo')
    end
  end
end
