class DiagnosticMethod < ApplicationRecord
    has_many :case_definitions

    validates_presence_of :name
end
