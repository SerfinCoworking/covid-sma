class InternalOrder < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  enum order_type: { provision: 0, solicitud: 1 }

  enum status: { solicitud_auditoria: 0, solicitud_enviada: 1, proveedor_auditoria: 2, provision_en_camino: 3, provision_entregada: 4, anulada: 5 }
  enum provider_status: { nuevo: 0, auditoria: 1, en_camino: 2, entregado: 3, anulado: 4 }, _prefix: :provider

  # Relaciones
  belongs_to :applicant_sector, class_name: 'Sector'
  belongs_to :provider_sector, class_name: 'Sector'
  has_many :quantity_ord_supply_lots, :as => :quantifiable, dependent: :destroy, inverse_of: :quantifiable
  has_many :sector_supply_lots, -> { with_deleted }, :through => :quantity_ord_supply_lots, dependent: :destroy
  has_many :supply_lots, -> { with_deleted }, :through => :sector_supply_lots
  has_many :supplies, -> { with_deleted }, :through => :quantity_ord_supply_lots

  belongs_to :created_by, class_name: 'User', optional: true
  belongs_to :audited_by, class_name: 'User', optional: true
  belongs_to :sent_by, class_name: 'User', optional: true
  belongs_to :received_by, class_name: 'User', optional: true
  belongs_to :sent_request_by, class_name: 'User', optional: true

  # Validaciones
  validates_presence_of :provider_sector
  validates_presence_of :applicant_sector
  validates_presence_of :requested_date
  validates_presence_of :quantity_ord_supply_lots
  validates_presence_of :remit_code
  validates_associated :quantity_ord_supply_lots
  validates_associated :sector_supply_lots
  validates_uniqueness_of :remit_code, conditions: -> { with_deleted }

  # Atributos anidados
  accepts_nested_attributes_for :quantity_ord_supply_lots,
    :reject_if => :all_blank,
    :allow_destroy => true

  filterrific(
    default_filter_params: { sorted_by: 'created_at_desc' },
    available_filters: [
      :search_applicant,
      :search_provider,
      :search_supply_code,
      :search_supply_name,
      :with_status,
      :requested_date_at,
      :received_date_at,
      :sorted_by
    ]
  )

  pg_search_scope :search_supply_code,
  :associated_against => { :supply_lots => :code },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_supply_name,
  :associated_against => { :supply_lots => :supply_name },
  :using => { :tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_applicant,
  :associated_against => { :applicant_sector => :name },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_applicant,
  :associated_against => { :provider_sector => :name },
  :using => {:tsearch => {:prefix => true} }, # Buscar coincidencia desde las primeras letras.
  :ignoring => :accents # Ignorar tildes.


  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      order("internal_orders.created_at #{ direction }")
    when /^solicitante_/
      # Ordenamiento por nombre de responsable
      order("LOWER(applicant_sector.name) #{ direction }").joins("INNER JOIN sectors as applicant_sector ON applicant_sector.id = internal_orders.applicant_sector_id")
    when /^insumos_solicitados_/
      # Ordenamiento por nombre de sector
      order("supplies.name #{ direction }").joins(:supplies)
    when /^estado_/
      # Ordenamiento por nombre de estado
      order("internal_orders.status #{ direction }")
    when /^recibido_/
      # Ordenamiento por la fecha de recepción
      order("internal_orders.date_received #{ direction }")
    when /^entregado_/
      # Ordenamiento por la fecha de dispensación
      order("internal_orders.date_delivered #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :requested_date_at, lambda { |reference_time|
    where('internal_orders.requested_date = ?', reference_time)
  }

  scope :received_date_at, lambda { |reference_time|
    where('internal_orders.received_date = ?', reference_time)
  }

  scope :with_sector_id, lambda { |an_id|
    where(sector_id: [*an_id])
  }

  scope :with_status, lambda { |a_status|
    where('internal_orders.provider_status = ?', a_status)
  }

  def self.applicant(a_sector)
    where(applicant_sector: a_sector)
  end

  def self.provider(a_sector)
    where(provider_sector: a_sector)
  end

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
    [
      ['Creación (desc)', 'created_at_desc'],
      ['Sector (a-z)', 'sector_asc'],
      ['Responsable (a-z)', 'responsable_asc'],
      ['Estado (a-z)', 'estado_asc'],
      ['Insumos solicitados (a-z)', 'insumos_solicitados_asc'],
      ['Fecha recibido (asc)', 'recibido_desc'],
      ['Fecha entregado (asc)', 'entregado_asc'],
      ['Cantidad (asc)', 'cantidad_asc']
    ]
  end

  # Cambia estado a "en camino" y descuenta la cantidad a los lotes de insumos
  def send_order_by_user_id(a_user_id)
    if self.proveedor_auditoria?
      if self.quantity_ord_supply_lots.exists?
        if self.quantity_ord_supply_lots.where.not(sector_supply_lot: nil).exists?
          self.quantity_ord_supply_lots.each do |qosl|
            qosl.decrement
          end
        else
          raise ArgumentError, 'No hay insumos a entregar en el pedido'
        end # End check if sector supply exists
      else
        raise ArgumentError, 'No hay insumos solicitados en el pedido'
      end # End check if quantity_ord_supply_lots exists
      self.sent_date = DateTime.now
      self.sent_by_id = a_user_id
      self.provision_en_camino!
    else
      raise ArgumentError, 'La '+self.order_type+' debe estar antes en proveedor auditoría.'
    end
  end

  def send_request_of(a_user)
    if self.solicitud_auditoria?
      self.sent_request_by = a_user
      self.solicitud_enviada!
    else
      raise ArgumentError, 'La solicitud no se encuentra en auditoría.'
    end
  end

  # Método para retornar perdido a estado anterior
  def return_provider_status
    if provision_en_camino?
      self.quantity_ord_supply_lots.each do |qosl|
        qosl.increment
      end
      self.sent_by = nil
      self.sent_date = nil
      self.proveedor_auditoria!
    else
      raise ArgumentError, "No es posible retornar a un estado anterior"
    end
  end

  # Método para retornar perdido a estado anterior
  def return_applicant_status
    if solicitud_enviada?
      self.solicitud_auditoria!
    else
      raise ArgumentError, "No es posible retornar a un estado anterior"
    end
  end

  # Cambia estado del pedido a "Aceptado" y se verifica que hayan lotes
  def receive_order(a_sector)
    if self.provision_en_camino?
      if self.quantity_ord_supply_lots.where.not(sector_supply_lot: nil).exists?
        self.quantity_ord_supply_lots.each do |qosl|
          qosl.increment_lot_to(a_sector)
        end
        self.date_received = DateTime.now
        self.provision_entregada!
      else
        raise ArgumentError, 'No hay insumos para recibir en la provisión.'
      end # End check if sector supply exists
    else
      raise ArgumentError, 'La provisión aún no está en camino.'
    end
  end

  def self.options_for_status
    [
      ['Todos', '', 'default'],
      ['Solicitud auditoria', 0, 'warning'],
      ['Solicitud enviada', 1, 'info'],
      ['Proveedor auditoria', 2, 'warning'],
      ['Provision en camino', 3, 'primary'],
      ['Provision entregada', 4, 'success'],
      ['Anulada', 5, 'danger'],
    ]
   end
end
