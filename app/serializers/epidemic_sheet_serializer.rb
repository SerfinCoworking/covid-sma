class EpidemicSheetSerializer < ActiveModel::Serializer
  attributes :id, :init_symptom_date, :epidemic_week, :presents_symptoms, :symptoms_observations, :previous_symptoms, :prev_symptoms_observations, :clinic_location
  has_one :patient
  has_one :case_definition
end
