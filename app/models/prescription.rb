class Prescription < ApplicationRecord

  belongs_to :professional
  belongs_to :patient
  #belongs_to :prescription_status

  has_many :quantity_medications, :as => :quantifiable, dependent: :destroy
  has_many :medications, :through => :quantity_medications
  has_many :quantity_supplies, :as => :quantifiable
  has_many :supplies, :through => :quantity_supplies


  accepts_nested_attributes_for :quantity_medications,
          :reject_if => :all_blank,
          :allow_destroy => true
  accepts_nested_attributes_for :medications
end
