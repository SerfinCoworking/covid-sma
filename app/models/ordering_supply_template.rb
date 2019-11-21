class OrderingSupplyTemplate < ApplicationRecord
  enum order_type: { solicitud: 0, despacho: 1 }

  belongs_to :owner_sector, class_name: 'Sector'
  belongs_to :destination_establishment, class_name: 'Establishment'
  belongs_to :destination_sector, class_name: 'Sector'
  belongs_to :created_by, class_name: "User"
  has_many :ordering_supply_template_supplies, -> { order(rank: :asc) }, dependent: :destroy, inverse_of: :ordering_supply_template
  has_many :supplies, through: :ordering_supply_template_supplies

  validates_presence_of :name
  validates_associated :ordering_supply_template_supplies

  accepts_nested_attributes_for :ordering_supply_template_supplies,
    reject_if: ->(qosl){ qosl['supply_id'].blank? },
    :allow_destroy => true
end
