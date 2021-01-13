class CaseStatus < ApplicationRecord
  has_many :case_definitions
  has_many :case_evolutions
  has_many :epidemic_sheets, through: :case_definitions

  validates_presence_of :name, :badge

  def self.total_positive
    self.find_by_name('Positivo').epidemic_sheets.count
  end
  
  def self.total_recovered
    self.find_by_name('Recuperado').epidemic_sheets.count
  end
end
