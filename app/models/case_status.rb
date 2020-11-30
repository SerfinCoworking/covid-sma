class CaseStatus < ApplicationRecord
  has_many :case_definition

  validates_presence_of :name, :badge
end
