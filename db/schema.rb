# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 2021_01_04_172760) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "fuzzystrmatch"
  enable_extension "pg_trgm"
  enable_extension "plpgsql"
  enable_extension "unaccent"

  create_table "active_storage_attachments", force: :cascade do |t|
    t.string "name", null: false
    t.string "record_type", null: false
    t.bigint "record_id", null: false
    t.bigint "blob_id", null: false
    t.datetime "created_at", null: false
    t.index ["blob_id"], name: "index_active_storage_attachments_on_blob_id"
    t.index ["record_type", "record_id", "name", "blob_id"], name: "index_active_storage_attachments_uniqueness", unique: true
  end

  create_table "active_storage_blobs", force: :cascade do |t|
    t.string "key", null: false
    t.string "filename", null: false
    t.string "content_type"
    t.text "metadata"
    t.bigint "byte_size", null: false
    t.string "checksum", null: false
    t.datetime "created_at", null: false
    t.index ["key"], name: "index_active_storage_blobs_on_key", unique: true
  end

  create_table "addresses", force: :cascade do |t|
    t.string "postal_code"
    t.text "line"
    t.bigint "city_id"
    t.bigint "country_id"
    t.bigint "state_id"
    t.bigint "latitude"
    t.bigint "longitude"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["city_id"], name: "index_addresses_on_city_id"
    t.index ["country_id"], name: "index_addresses_on_country_id"
    t.index ["state_id"], name: "index_addresses_on_state_id"
  end

  create_table "case_count_per_days", force: :cascade do |t|
    t.bigint "case_status_id"
    t.integer "count"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_status_id"], name: "index_case_count_per_days_on_case_status_id"
  end

  create_table "case_definitions", force: :cascade do |t|
    t.bigint "diagnostic_method_id"
    t.bigint "case_status_id", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "special_device_id", default: 1
    t.index ["case_status_id"], name: "index_case_definitions_on_case_status_id"
    t.index ["diagnostic_method_id"], name: "index_case_definitions_on_diagnostic_method_id"
    t.index ["special_device_id"], name: "index_case_definitions_on_special_device_id"
  end

  create_table "case_evolutions", force: :cascade do |t|
    t.bigint "case_status_id"
    t.bigint "diagnostic_method_id"
    t.bigint "epidemic_sheet_id"
    t.bigint "patient_id"
    t.bigint "special_device_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["case_status_id"], name: "index_case_evolutions_on_case_status_id"
    t.index ["diagnostic_method_id"], name: "index_case_evolutions_on_diagnostic_method_id"
    t.index ["epidemic_sheet_id"], name: "index_case_evolutions_on_epidemic_sheet_id"
    t.index ["patient_id"], name: "index_case_evolutions_on_patient_id"
    t.index ["special_device_id"], name: "index_case_evolutions_on_special_device_id"
  end

  create_table "case_statuses", force: :cascade do |t|
    t.string "name"
    t.bigint "case_status_id", default: 1
    t.string "badge", default: "secondary"
    t.boolean "needs_diagnostic", default: false
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.boolean "needs_fis", default: false
    t.index ["case_status_id"], name: "index_case_statuses_on_case_status_id"
  end

  create_table "cities", force: :cascade do |t|
    t.bigint "state_id"
    t.string "name"
    t.index ["state_id"], name: "index_cities_on_state_id"
  end

  create_table "close_contacts", force: :cascade do |t|
    t.bigint "epidemic_sheet_id"
    t.bigint "patient_id"
    t.bigint "contact_type_id"
    t.string "full_name"
    t.string "dni"
    t.string "phone"
    t.string "address"
    t.date "last_contact_date"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "contact_id"
    t.index ["contact_id"], name: "index_close_contacts_on_contact_id"
    t.index ["contact_type_id"], name: "index_close_contacts_on_contact_type_id"
    t.index ["epidemic_sheet_id"], name: "index_close_contacts_on_epidemic_sheet_id"
    t.index ["patient_id"], name: "index_close_contacts_on_patient_id"
  end

  create_table "contact_types", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "countries", force: :cascade do |t|
    t.string "name"
    t.string "iso2"
    t.string "iso3"
    t.string "phone_code"
  end

  create_table "current_addresses", force: :cascade do |t|
    t.string "neighborhood"
    t.string "street"
    t.string "street_number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "diagnostic_methods", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "epidemic_sheet_movements", force: :cascade do |t|
    t.bigint "epidemic_sheet_id"
    t.bigint "user_id"
    t.bigint "sector_id"
    t.string "action"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["epidemic_sheet_id"], name: "index_epidemic_sheet_movements_on_epidemic_sheet_id"
    t.index ["sector_id"], name: "index_epidemic_sheet_movements_on_sector_id"
    t.index ["user_id"], name: "index_epidemic_sheet_movements_on_user_id"
  end

  create_table "epidemic_sheets", force: :cascade do |t|
    t.bigint "patient_id"
    t.bigint "case_definition_id"
    t.bigint "created_by_id"
    t.bigint "establishment_id"
    t.date "init_symptom_date"
    t.integer "epidemic_week", default: 0
    t.boolean "presents_symptoms"
    t.text "symptoms_observations"
    t.boolean "present_previous_symptoms"
    t.text "prev_symptoms_observations"
    t.integer "clinic_location", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "parent_contact_id"
    t.bigint "locked_close_contact_id"
    t.boolean "is_in_sisa", default: false
    t.date "notification_date"
    t.index ["case_definition_id"], name: "index_epidemic_sheets_on_case_definition_id"
    t.index ["created_by_id"], name: "index_epidemic_sheets_on_created_by_id"
    t.index ["establishment_id"], name: "index_epidemic_sheets_on_establishment_id"
    t.index ["locked_close_contact_id"], name: "index_epidemic_sheets_on_locked_close_contact_id"
    t.index ["parent_contact_id"], name: "index_epidemic_sheets_on_parent_contact_id"
    t.index ["patient_id"], name: "index_epidemic_sheets_on_patient_id"
  end

  create_table "establishments", force: :cascade do |t|
    t.string "code"
    t.string "name"
    t.string "short_name"
    t.string "cuit"
    t.string "domicile"
    t.string "phone"
    t.string "email"
    t.integer "sectors_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "internal_orders", force: :cascade do |t|
    t.bigint "audited_by_id"
    t.bigint "sent_by_id"
    t.bigint "received_by_id"
    t.bigint "created_by_id"
    t.datetime "sent_date"
    t.datetime "requested_date"
    t.datetime "date_received"
    t.text "observation"
    t.integer "provider_status", default: 0
    t.integer "applicant_status", default: 0
    t.integer "status", default: 0
    t.integer "order_type", default: 0
    t.string "remit_code"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "provider_sector_id"
    t.bigint "applicant_sector_id"
    t.datetime "deleted_at"
    t.bigint "sent_request_by_id"
    t.index ["applicant_sector_id"], name: "index_internal_orders_on_applicant_sector_id"
    t.index ["audited_by_id"], name: "index_internal_orders_on_audited_by_id"
    t.index ["created_by_id"], name: "index_internal_orders_on_created_by_id"
    t.index ["deleted_at"], name: "index_internal_orders_on_deleted_at"
    t.index ["provider_sector_id"], name: "index_internal_orders_on_provider_sector_id"
    t.index ["received_by_id"], name: "index_internal_orders_on_received_by_id"
    t.index ["remit_code"], name: "index_internal_orders_on_remit_code", unique: true
    t.index ["sent_by_id"], name: "index_internal_orders_on_sent_by_id"
    t.index ["sent_request_by_id"], name: "index_internal_orders_on_sent_request_by_id"
  end

  create_table "notifications", id: :serial, force: :cascade do |t|
    t.integer "user_id", null: false
    t.integer "actor_id"
    t.string "notify_type", null: false
    t.string "target_type"
    t.integer "target_id"
    t.string "second_target_type"
    t.integer "second_target_id"
    t.string "third_target_type"
    t.integer "third_target_id"
    t.datetime "read_at"
    t.string "action_type"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "actor_sector_id"
    t.index ["actor_sector_id"], name: "index_notifications_on_actor_sector_id"
    t.index ["user_id", "notify_type"], name: "index_notifications_on_user_id_and_notify_type"
    t.index ["user_id"], name: "index_notifications_on_user_id"
  end

  create_table "occupations", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patient_phones", force: :cascade do |t|
    t.integer "phone_type", default: 1
    t.string "number"
    t.bigint "patient_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["patient_id"], name: "index_patient_phones_on_patient_id"
  end

  create_table "patient_types", force: :cascade do |t|
    t.string "name"
    t.string "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "patients", force: :cascade do |t|
    t.string "andes_id"
    t.string "first_name", limit: 100
    t.string "last_name", limit: 100
    t.integer "status", default: 0
    t.integer "dni"
    t.integer "sex", default: 1
    t.integer "marital_status", default: 1
    t.datetime "birthdate"
    t.string "email", limit: 50
    t.string "cuil"
    t.bigint "patient_type_id", default: 1
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "address_id"
    t.bigint "occupation_id"
    t.bigint "current_address_id"
    t.integer "assigned_establishment_id", default: 0
    t.bigint "parent_contact_id"
    t.index ["address_id"], name: "index_patients_on_address_id"
    t.index ["andes_id"], name: "index_patients_on_andes_id"
    t.index ["current_address_id"], name: "index_patients_on_current_address_id"
    t.index ["occupation_id"], name: "index_patients_on_occupation_id"
    t.index ["parent_contact_id"], name: "index_patients_on_parent_contact_id"
    t.index ["patient_type_id"], name: "index_patients_on_patient_type_id"
  end

  create_table "permission_requests", force: :cascade do |t|
    t.bigint "user_id"
    t.integer "status", default: 0
    t.string "establishment"
    t.string "sector"
    t.string "role"
    t.text "observation"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_permission_requests_on_user_id"
  end

  create_table "previous_symptoms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "professional_types", force: :cascade do |t|
    t.string "name", limit: 50
  end

  create_table "professionals", force: :cascade do |t|
    t.string "first_name", limit: 50
    t.string "last_name", limit: 50
    t.string "fullname", limit: 102
    t.integer "dni"
    t.string "enrollment", limit: 20
    t.string "email"
    t.string "phone"
    t.integer "sex", default: 1
    t.boolean "is_active", default: true
    t.string "docket", limit: 10
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "professional_type_id", default: 5
    t.index ["professional_type_id"], name: "index_professionals_on_professional_type_id"
    t.index ["user_id"], name: "index_professionals_on_user_id"
  end

  create_table "profiles", force: :cascade do |t|
    t.string "first_name"
    t.string "last_name"
    t.date "date_of_birth"
    t.integer "dni"
    t.string "enrollment"
    t.string "address"
    t.string "email"
    t.integer "sex", default: 1
    t.bigint "user_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["user_id"], name: "index_profiles_on_user_id"
  end

  create_table "roles", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "resource_type"
    t.integer "resource_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["name", "resource_type", "resource_id"], name: "index_roles_on_name_and_resource_type_and_resource_id"
    t.index ["name"], name: "index_roles_on_name"
    t.index ["resource_type", "resource_id"], name: "index_roles_on_resource_type_and_resource_id"
  end

  create_table "sectors", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.integer "complexity_level"
    t.integer "user_sectors_count", default: 0
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "establishment_id"
    t.index ["establishment_id"], name: "index_sectors_on_establishment_id"
  end

  create_table "sheet_previous_symptoms", force: :cascade do |t|
    t.bigint "epidemic_sheet_id"
    t.bigint "previous_symptom_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["epidemic_sheet_id"], name: "index_sheet_previous_symptoms_on_epidemic_sheet_id"
    t.index ["previous_symptom_id"], name: "index_sheet_previous_symptoms_on_previous_symptom_id"
  end

  create_table "sheet_symptoms", force: :cascade do |t|
    t.bigint "epidemic_sheet_id"
    t.bigint "symptom_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["epidemic_sheet_id"], name: "index_sheet_symptoms_on_epidemic_sheet_id"
    t.index ["symptom_id"], name: "index_sheet_symptoms_on_symptom_id"
  end

  create_table "special_devices", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "states", force: :cascade do |t|
    t.bigint "country_id"
    t.string "name"
    t.index ["country_id"], name: "index_states_on_country_id"
  end

  create_table "symptoms", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "user_sectors", force: :cascade do |t|
    t.bigint "user_id"
    t.bigint "sector_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["sector_id"], name: "index_user_sectors_on_sector_id"
    t.index ["user_id"], name: "index_user_sectors_on_user_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "username", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0, null: false
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.inet "current_sign_in_ip"
    t.inet "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "sector_id"
    t.index ["sector_id"], name: "index_users_on_sector_id"
    t.index ["username"], name: "index_users_on_username", unique: true
  end

  create_table "users_roles", id: false, force: :cascade do |t|
    t.integer "user_id"
    t.integer "role_id"
    t.index ["role_id"], name: "index_users_roles_on_role_id"
    t.index ["user_id", "role_id"], name: "index_users_roles_on_user_id_and_role_id"
    t.index ["user_id"], name: "index_users_roles_on_user_id"
  end

  add_foreign_key "active_storage_attachments", "active_storage_blobs", column: "blob_id"
  add_foreign_key "addresses", "cities"
  add_foreign_key "cities", "states"
  add_foreign_key "patient_phones", "patients"
  add_foreign_key "patients", "addresses"
  add_foreign_key "patients", "current_addresses"
  add_foreign_key "permission_requests", "users"
  add_foreign_key "states", "countries"
  add_foreign_key "users", "sectors"
end
