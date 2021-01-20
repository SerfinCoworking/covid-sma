class CaseStatus < ApplicationRecord
  has_many :case_definitions
  has_many :case_evolutions
  has_many :epidemic_sheets, through: :case_definitions
  has_many :establishments, through: :epidemic_sheets

  validates_presence_of :name, :badge

  def self.total_positives_to_city(a_city)
    self.find_by_name('Positivo').epidemic_sheets.by_city(a_city).count
  end
  
  def self.total_recovered_to_city(a_city)
    self.find_by_name('Recuperado').epidemic_sheets.by_city(a_city).count
  end
end
