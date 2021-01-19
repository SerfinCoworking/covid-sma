class Sector < ApplicationRecord
  include PgSearch

  # Relaciones
  belongs_to :establishment, counter_cache: true
  belongs_to :establishment, counter_cache: :sectors_count
  has_many :user_sectors
  has_many :users, :through => :user_sectors

  # Validaciones
  validates_presence_of :name, :establishment_id

  delegate :name, :short_name, :city, to: :establishment, prefix: :establishment

  # SCOPES #--------------------------------------------------------------------
  pg_search_scope :search_name,
    against: :name,
    :using => {
      :tsearch => {:prefix => true} # Buscar coincidencia desde las primeras letras.
    },
    :ignoring => :accents # Ignorar tildes.

  filterrific(
    default_filter_params: { sorted_by: 'name_asc' },
    available_filters: [
      :search_name,
      :sorted_by,
    ]
  )

  def self.options_for_select
    order('LOWER(name)').map { |e| [e.name, e.id] }
  end

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^created_at_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("sectors.created_at #{ direction }")
    when /^name_/s
      # Ordenamiento por fecha de creación en la BD
      reorder("sectors.name #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }

  scope :with_establishment_id, lambda { |an_id|
    where(establishment_id: [*an_id])
  }

  def establishment_name
    self.establishment.name
  end

  def sector_and_establishment
    self.name+' de '+self.establishment.name
  end
end
