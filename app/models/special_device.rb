class SpecialDevice < ApplicationRecord
  has_many :case_definitions
  has_many :case_evolutions
end
