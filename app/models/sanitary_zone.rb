class SanitaryZone < ApplicationRecord
  belongs_to :state, optional: true
  has_many :departments
  has_many :establishments, through: :departments
  has_many :epidemic_sheets, through: :establishments

  validates_presence_of :name

  filterrific(
    default_filter_params: { sorted_by: 'nombre_desc' },
    available_filters: [
      :sorted_by,
      :search_name,
    ]
  )

  scope :by_city, lambda {|ids_ary| 
    where(city_id: ids_ary)
  }

  scope :where_not_id, lambda { |an_id|
    where.not(id: [*an_id])
  }

  scope :sorted_by, lambda { |sort_option|
    # extract the sort direction from the param value.
    direction = (sort_option =~ /desc$/) ? 'desc' : 'asc'
    case sort_option.to_s
    when /^nombre_/s
      reorder("sanitary_zones.name #{ direction }")
    when /^departamentos_/
      left_joins(:departments)
      .group(:id)
      .reorder("COUNT(departments.id) #{ direction }")
    when /^establecimientos_/
      left_joins(:establishments)
      .group(:id)
      .reorder("COUNT(establishments.id) #{ direction }")
    else
      # Si no existe la opcion de ordenamiento se levanta la excepcion
      raise(ArgumentError, "Invalid sort option: #{ sort_option.inspect }")
    end
  }
end
