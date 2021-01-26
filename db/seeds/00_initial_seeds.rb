require 'csv'

# Country
csv_text = File.read(Rails.root.join('lib', 'seeds', 'countries.csv'))
csv = CSV.parse(csv_text, :encoding => 'bom|utf-8', headers: :first_row)
puts "Start COUNTRIES import"
csv.each do |row|
  if !row['name'].nil? && row['name'].present? && !row['name'].include?("#<Country")
    country = Country.new
    country.id = row['id']
    country.name = row['name'],
    country.iso2 = row['iso2'],
    country.iso3 = row['iso3'],
    country.phone_code = row['phone_code']
    country.save
  end
end
puts "End COUNTRIES import: " + Country.all.count.to_s

# State
csv_text = File.read(Rails.root.join('lib', 'seeds', 'states.csv'))
csv = CSV.parse(csv_text, :encoding => 'bom|utf-8', headers: :first_row)
puts "Start STATES import"
csv.each do |row|
  if !row['name'].nil? && row['name'].present? && !row['name'].include?("#<State")
    state = State.new
    state.id = row['id']
    state.name = row['name']
    state.country_id = row['country_id']
    state.save
  end
end
puts "End STATES import: " + State.all.count.to_s

# Sanitary Zone
csv_text = File.read(Rails.root.join('lib', 'seeds', 'sanitary_zones.csv'))
csv = CSV.parse(csv_text, :encoding => 'bom|utf-8', headers: :first_row)
puts "Start Sanitary Zones import"
csv.each do |row|
  if !row['name'].nil? && row['name'].present?

    sanitaryZone = SanitaryZone.new
    sanitaryZone.id = row['id']
    sanitaryZone.name = row['name']
    sanitaryZone.save
  end
end
puts "End Sanitary Zones import: " + SanitaryZone.all.count.to_s

# Department
csv_text = File.read(Rails.root.join('lib', 'seeds', 'departments.csv'))
csv = CSV.parse(csv_text, :encoding => 'bom|utf-8', headers: :first_row)
puts "Start Departments import"
csv.each do |row|
  if !row['name'].nil? && row['name'].present?
    department = Department.new
    department.id = row['id']
    department.name = row['name']
    department.state_id = row['state_id'].present? ? row['state_id'] : ''
    department.sanitary_zone_id = row['sanitary_zone_id'].present? ? row['sanitary_zone_id'] : ''
    department.save    
  end
end
puts "End Departments import: " + Department.all.count.to_s

# Volver a importar cities
csv_text = File.read(Rails.root.join('lib', 'seeds', 'cities.csv'))
csv = CSV.parse(csv_text, :encoding => 'bom|utf-8', headers: :first_row)
puts "Start CITIES import"
csv.each do |row|
  
  if !row['name'].nil? && row['name'].present? && !row['state_id'].nil? && row['state_id'].present?
    
    city = City.new
    city.id = row['id']
    city.name = row['name']
    city.state_id = row['state_id'].present? ? row['state_id'] : ''
    city.department_id = row['department_id'].present? ? row['department_id'] : ''
    city.save    
  end
end
puts "End CITIES import: " + City.all.count.to_s