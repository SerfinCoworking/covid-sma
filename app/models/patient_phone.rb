class PatientPhone < ApplicationRecord
  enum phone_type: { Celular: 1, Fijo: 2 }

  belongs_to :patient

  # validates_uniqueness_of :number, scope: [:patient_id]
end
