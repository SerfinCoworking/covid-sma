class SectorSupplyLot < ApplicationRecord
  acts_as_paranoid
  include PgSearch

  enum status: { vigente: 0, por_vencer: 1, vencido: 2, agotado: 3 }

  # Callbacks
  after_validation :update_status
  before_validation :assign_constants

  # Relaciones
  belongs_to :sector
  belongs_to :supply_lot, -> { with_deleted }

  has_many :quantity_supply_lots
  has_many :prescriptions, -> { with_deleted },
    :through => :quantity_supply_lots,
    :source => :quantifiable,
    :source_type => 'Prescription'

  has_many :internal_orders, -> { with_deleted },
    :through => :quantity_supply_lots,
    :source => :quantifiable,
    :source_type => 'InternalOrder'

  # Validaciones
  validates_presence_of :supply_lot
  validates_presence_of :quantity
  validates_presence_of :initial_quantity

  filterrific(
    default_filter_params: { sorted_by: 'insumo_asc' },
    available_filters: [
      :with_code,
      :sorted_by,
      :with_status,
      :search_supply_name,
      :date_received_at
    ]
  )

  # SCOPES #--------------------------------------------------------------------

  pg_search_scope :with_code,
  :associated_against => {
    :supply_lot => :code
  },
  :ignoring => :accents # Ignorar tildes.

  pg_search_scope :search_supply_name,
  associated_against: { :supply_lot => :supply_name },
  :using => {
    :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
  },
  :ignoring => :accents # Ignorar tildes.

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^recepcion_/
      # Ordenamiento por fecha de recepción
      order("sector_supply_lots.created_at #{ direction }")
    when /^lote_/
      # Ordenamiento por código de lote
      order("LOWER(supply_lots.lot_code) #{ direction }").joins(:supply_lot)
    when /^cod_ins_/
      # Ordenamiento por código de lote
      order("LOWER(supply_lots.code) #{ direction }").joins(:supply_lot)
    when /^insumo_/
      # Ordenamiento por nombre del insumo
      order("LOWER(supply_lots.supply_name) #{ direction }").joins(:supply_lot)
    when /^estado_/
      # Ordenamiento por estado del lote
      order("sector_supply_lots.status #{ direction }")
    when /^cantidad_inicial_/
      # Ordenamiento por cantidad inicial del lote
      order("sector_supply_lots.initial_quantity #{ direction }")
    when /^cantidad_/
      # Ordenamiento por cantidad actual del lote
      order("sector_supply_lots.quantity #{ direction }")
    when /^vencimiento_/
      # Ordenamiento por fecha de expiración
      order("supply_lots.expiry_date #{ direction }").joins(:supply_lot)
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :date_received_at, lambda { |reference_time|
    where('sector_supply_lots.created_at >= ?', reference_time)
  }

  scope :with_status, lambda { |a_status|
    where('sector_supply_lots.status = ?', a_status)
  }

  scope :without_status, lambda { |a_status|
    where.not('sector_supply_lots.status = ?', a_status )
  }

  # Métodos públicos #----------------------------------------------------------

  def laboratory
    self.supply_lot.laboratory_name
  end

  def increment(a_quantity)
    self.quantity = 0 unless self.quantity.present?
    self.quantity += a_quantity
  end

  # Disminuye la cantidad
  def decrement(a_quantity)
    if self.quantity < a_quantity
      raise ArgumentError, "Cantidad en stock insuficiente de lote N°"+self.id.to_s+" insumo "+self.supply_name
    elsif self.deleted?
      raise ArgumentError, "El lote N°"+self.id.to_s+" de "+self.supply_name+" se encuentra en la papelera"
    else
      self.quantity -= a_quantity
    end
  end

  # Retorna el porcentaje actual de stock
  def percent_stock
    self.quantity.to_f / self.initial_quantity  * 100
  end

  # Label de porcentaje de stock para vista.
  def quantity_label
    if self.percent_stock == 0 || self.percent_stock.nil?
      return 'danger'
    elsif self.percent_stock <= 30
      return 'warning'
    else
      return 'success'
    end
  end

  # Label del estado para vista.
  def status_label
    if self.vigente?
      return 'success'
    elsif self.por_vencer?
      return 'warning'
    elsif self.vencido?
      return 'danger'
    elsif self.agotado?
      return 'info'
    elsif self.auditoria?
      return 'info'
    end
  end

  def code
    self.supply_lot.code
  end

  def lot_code
    self.supply_lot.lot_code
  end

  def supply_name
    self.supply_lot.supply_name
  end

  # Retorna el tipo de unidad
  def unity
    self.supply_lot.unity
  end

  def needs_expiration?
    self.supply_lot.needs_expiration?
  end

  def expiry_date
    self.supply_lot.expiry_date
  end

  # Se actualiza el estado del lote
  def update_status!
    if self.quantity == 0
      self.agotado!
    elsif self.supply_lot.expiry_date.present?
      @exp_date = self.supply_lot.expiry_date
      # If expired
      if @exp_date <= DateTime.now
        self.vencido!
      # If near_expiry
      elsif @exp_date < DateTime.now + 3.month && @exp_date > DateTime.now
        self.por_vencer!
      # If good
      elsif @exp_date > DateTime.now
        self.vigente!
      end 
    else
      self.vigente!
    end
  end

  # Métodos privados #----------------------------------------------------------

  private
  # Se actualiza el estado del lote
  def update_status
    if self.quantity == 0
      self.status = 'agotado'
    elsif self.supply_lot.expiry_date.present?
      @exp_date = self.supply_lot.expiry_date
      # If expired
      if @exp_date <= DateTime.now
        self.status = 'vencido'
      # If near_expiry
      elsif @exp_date < DateTime.now + 3.month && @exp_date > DateTime.now
        self.status = 'por_vencer'
      # If good
      elsif @exp_date > DateTime.now
        self.status = 'vigente'
      end 
    else
      self.status = 'vigente'
    end
  end

  # Se asigna la cantidad inicial
  def assign_constants
    if self.initial_quantity.present? && self.initial_quantity < self.quantity # Si se edita y coloca una cantidad mayor a la inicial
      self.initial_quantity = self.quantity # Se vuelve a asignar la cantidad inicial
    end
    self.initial_quantity = self.quantity unless initial_quantity.present?
  end

  # Métodos de clase #----------------------------------------------------------

  def self.lots_for_sector(a_sector)
    where(sector: a_sector)
  end

  # Método para establecer las opciones del select input del filtro
  # Es llamado por el controlador como parte de `initialize_filterrific`.
  def self.options_for_sorted_by
   [
     ['Fecha recepción (desc)', 'recepcion_desc'],
     ['Fecha vencimiento (asc)', 'vencimiento_asc'],
     ['Código de lote (asc)', 'lote_asc'],
     ['Código de insumo (asc)', 'cod_ins_asc'],
     ['Insumo (a-z)', 'insumo_asc'],
     ['Estado', 'estado_asc'],
     ['Cantidad (asc)', 'cantidad_asc'],
     ['Cantidad inicial (asc)', 'cantidad_inicial_asc'],
   ]
  end

  def self.options_for_status
   [
     ['Todos', '', 'primary'],
     ['Vigentes', 0, 'success'],
     ['Por vencer', 1, 'warning'],
     ['Vencidos', 2, 'danger'],
     ['Agotados', 3, 'info'],
   ]
  end
end
