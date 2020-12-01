class CaseStatus < ApplicationRecord
  has_many :case_definition
  has_many :case_evolutions

  validates_presence_of :name, :badge
end
