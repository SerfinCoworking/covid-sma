class CreateSanitaryZones < ActiveRecord::Migration[5.2]
  def change
    create_table :sanitary_zones do |t|
      t.string :name
      t.references :state, index: true

      t.timestamps
    end
    SanitaryZone.create(name: 'Zona Metropolitana')
    SanitaryZone.create(name: 'Zona Sanitaria I')
    SanitaryZone.create(name: 'Zona Sanitaria II')
    SanitaryZone.create(name: 'Zona Sanitaria III')
    SanitaryZone.create(name: 'Zona Sanitaria IV')
    SanitaryZone.create(name: 'Zona Sanitaria V')
  end
end
