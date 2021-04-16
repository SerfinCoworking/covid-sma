class CreateEpidemiAntecedents < ActiveRecord::Migration[5.2]
  def change
    create_table :epidemi_antecedents do |t|
      t.string :name
      t.timestamps
    end

    EpidemiAntecedent.create(name: "Contacto estrecho de caso confirmado en últimos 14 días")
    EpidemiAntecedent.create(name: "Viaje al exterior en últimos 14 días")
    EpidemiAntecedent.create(name: "Vacunado covid 1° dosis")
    EpidemiAntecedent.create(name: "Vacunado covid 2° (agregar fecha de vacunación)")
    EpidemiAntecedent.create(name: "Burbuja escolar")
    EpidemiAntecedent.create(name: "Pertenece a comunidad cerrada")
    EpidemiAntecedent.create(name: "Internación en los últimos 14 días")
    EpidemiAntecedent.create(name: "Posible transmisión comunitaria")
    EpidemiAntecedent.create(name: "Sin nexo")
  end
end
