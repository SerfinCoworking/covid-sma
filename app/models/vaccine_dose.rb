class VaccineDose < ApplicationRecord
  belongs_to :vaccines_applied

  validates_presence_of :date_applied
  validate :date_applied_cannot_be_in_the_future

  def date_applied_cannot_be_in_the_future
    if date_applied.present? && date_applied > Date.today
      errors.add(:date_applied_future, "La fecha de aplicación no puede estar en días futuros")
    end
  end
end
