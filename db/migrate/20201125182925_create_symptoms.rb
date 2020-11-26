class CreateSymptoms < ActiveRecord::Migration[5.2]
  def change
    create_table :symptoms do |t|
      t.string :name
      t.timestamps
    end

    Symptom.create(name: "Anosmia de reciente aparición")
    Symptom.create(name: "Artralgias")
    Symptom.create(name: "Cefalea")
    Symptom.create(name: "Coma")
    Symptom.create(name: "Confusión mental")
    Symptom.create(name: "Convulsiones")
    Symptom.create(name: "Diarrea")
    Symptom.create(name: "Sindrome inflamatorio multisistémico")
    Symptom.create(name: "Disgeusia")
    Symptom.create(name: "Disnea / Taquipnea (frecuencia según la edad)")
    Symptom.create(name: "Dolor abdominal")
    Symptom.create(name: "Dolor torácico")
    Symptom.create(name: "Evidencia clínica y radiológica de Neumonía")
    Symptom.create(name: "Fiebre (37,5° C o más)")
    Symptom.create(name: "Inyección conjuntival")
    Symptom.create(name: "Irritabilidad")
    Symptom.create(name: "Malestar general")
    Symptom.create(name: "Mialgias")
    Symptom.create(name: "Odinofagia")
    Symptom.create(name: "Rechazo del alimento")
    Symptom.create(name: "Tiraje")
    Symptom.create(name: "Tos")
    Symptom.create(name: "Vómitos")
  end
end
