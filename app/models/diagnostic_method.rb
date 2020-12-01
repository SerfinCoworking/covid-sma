class DiagnosticMethod < ApplicationRecord
    has_many :case_definitions
    has_many :case_evolutions

    validates_presence_of :name
end
