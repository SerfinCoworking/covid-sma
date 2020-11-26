class CreatePreviousSymptoms < ActiveRecord::Migration[5.2]
  def change
    create_table :previous_symptoms do |t|
      t.string :name
      t.timestamps
    end

    PreviousSymptom.create(name: "Asma")
    PreviousSymptom.create(name: "Bajo Peso al nacer")
    PreviousSymptom.create(name: "Bronquiolitis previa")
    PreviousSymptom.create(name: "Diabetes")
    PreviousSymptom.create(name: "Diálisis aguda")
    PreviousSymptom.create(name: "Diálisis crónica")
    PreviousSymptom.create(name: "Embarazo")
    PreviousSymptom.create(name: "Puerperio")
    PreviousSymptom.create(name: "Enfermedad hepática")
    PreviousSymptom.create(name: "Enfermedad neurológica")
    PreviousSymptom.create(name: "Enfermedad oncológica")
    PreviousSymptom.create(name: "Enfermedad Renal Crónica")
    PreviousSymptom.create(name: "EPOC")
    PreviousSymptom.create(name: "Ex fumador")
    PreviousSymptom.create(name: "Fumador")
    PreviousSymptom.create(name: "Hipertensión arterial")
    PreviousSymptom.create(name: "Inmunosupresión congénita o adquirida")
    PreviousSymptom.create(name: "Insuficiencia cardíaca")
    PreviousSymptom.create(name: "N.A.C. previa")
    PreviousSymptom.create(name: "Obesidad")
    PreviousSymptom.create(name: "Prematuridad")
    PreviousSymptom.create(name: "Tuberculosis")
  end
end
