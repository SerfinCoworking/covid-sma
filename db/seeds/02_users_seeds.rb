# IMPORTANTE!!!!!:
# Antes de ejecutar el seed se debe comentar la linea 24 y 45 del modelo User (:create_profile)

##########################
sectorInformatico = Sector.find_by_name("Informática")
# Creacion de usuarios
eugeUser = User.new(
  :username              => "38601813",
  :password              => "12345678",
  :password_confirmation => "12345678",
)

UserSector.create(user:eugeUser, sector: sectorInformatico)
eugeUser.add_role :admin
eugeUser.sector = sectorInformatico
eugeUser.save!

Profile.create(user: eugeUser, first_name: "Eugenio", last_name: "Gomez", email: "euge@exmaple.com", dni: "38601813")

paul = User.new(
  :username              => "37458993",
  :password              => "12345678",
  :password_confirmation => "12345678",
)

UserSector.create(user: paul, sector: sectorInformatico)
paul.add_role :admin
paul.sector = sectorInformatico
paul.save!
Profile.create(user: paul, first_name: "Paul", last_name: "ibaceta", email: "paul@exmaple.com", dni: "37458993")

damian = User.new(
  :username              => "28989316",
  :password              => "12345678",
  :password_confirmation => "12345678",
)

UserSector.create(user: damian, sector: sectorInformatico)
damian.add_role :admin
damian.sector = sectorInformatico
damian.save!
Profile.create(user: damian, first_name: "Damián", last_name: "Diez", email: "damian@exmaple.com", dni: "28989316")
