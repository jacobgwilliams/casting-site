# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_08_01_170600) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "citext"
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pgcrypto"

  create_table "actor_attributes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_profile_id", null: false
    t.datetime "created_at", null: false
    t.uuid "profile_attribute_id", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false, null: false
    t.string "visibility", default: "private", null: false
    t.index ["actor_profile_id", "profile_attribute_id"], name: "index_actor_attributes_unique", unique: true
    t.index ["actor_profile_id"], name: "index_actor_attributes_on_actor_profile_id"
    t.index ["profile_attribute_id"], name: "index_actor_attributes_on_profile_attribute_id"
  end

  create_table "actor_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "primary_location"
    t.string "professional_name"
    t.string "profile_status", default: "draft", null: false
    t.string "timezone"
    t.string "union_status"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["profile_status"], name: "index_actor_profiles_on_profile_status"
    t.index ["user_id"], name: "index_actor_profiles_on_user_id", unique: true
  end

  create_table "actor_representation_contacts", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_representation_division_id", null: false
    t.datetime "created_at", null: false
    t.date "ended_on"
    t.boolean "is_primary", default: false, null: false
    t.uuid "representative_profile_id", null: false
    t.date "started_on"
    t.datetime "updated_at", null: false
    t.index ["actor_representation_division_id"], name: "index_actor_rep_contacts_on_division"
    t.index ["representative_profile_id"], name: "index_actor_rep_contacts_on_rep"
  end

  create_table "actor_representation_divisions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_representation_id", null: false
    t.datetime "created_at", null: false
    t.uuid "division_id", null: false
    t.date "ended_on"
    t.date "started_on"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_representation_id", "division_id", "started_on"], name: "index_actor_rep_divisions_unique", unique: true
    t.index ["actor_representation_id"], name: "index_actor_rep_divisions_on_representation"
    t.index ["division_id"], name: "index_actor_representation_divisions_on_division_id"
  end

  create_table "actor_representations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_profile_id", null: false
    t.datetime "confirmed_at"
    t.datetime "created_at", null: false
    t.date "ended_on"
    t.boolean "exclusive", default: false, null: false
    t.uuid "invited_by_user_id"
    t.text "notes"
    t.uuid "organization_id", null: false
    t.date "started_on"
    t.string "status", default: "pending", null: false
    t.datetime "updated_at", null: false
    t.index ["actor_profile_id", "organization_id"], name: "index_actor_reps_on_actor_and_org"
    t.index ["actor_profile_id"], name: "index_actor_representations_on_actor_profile_id"
    t.index ["invited_by_user_id"], name: "index_actor_representations_on_invited_by_user_id"
    t.index ["organization_id"], name: "index_actor_representations_on_organization_id"
    t.index ["status"], name: "index_actor_representations_on_status"
  end

  create_table "actor_skills", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "actor_profile_id", null: false
    t.datetime "created_at", null: false
    t.text "notes"
    t.string "proficiency"
    t.uuid "skill_id", null: false
    t.datetime "updated_at", null: false
    t.boolean "verified", default: false, null: false
    t.integer "years_experience"
    t.index ["actor_profile_id", "skill_id"], name: "index_actor_skills_on_actor_profile_id_and_skill_id", unique: true
    t.index ["actor_profile_id"], name: "index_actor_skills_on_actor_profile_id"
    t.index ["skill_id"], name: "index_actor_skills_on_skill_id"
  end

  create_table "breakdown_access_grants", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "access_level", default: "view", null: false
    t.uuid "breakdown_id", null: false
    t.datetime "created_at", null: false
    t.datetime "expires_at"
    t.uuid "grantee_id", null: false
    t.string "grantee_type", null: false
    t.datetime "updated_at", null: false
    t.index ["breakdown_id"], name: "index_breakdown_access_grants_on_breakdown_id"
    t.index ["grantee_type", "grantee_id"], name: "index_breakdown_access_grants_on_grantee_type_and_grantee_id"
  end

  create_table "breakdown_attribute_requirements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "breakdown_id", null: false
    t.text "context"
    t.datetime "created_at", null: false
    t.uuid "profile_attribute_id", null: false
    t.string "requirement_level", default: "required", null: false
    t.datetime "updated_at", null: false
    t.index ["breakdown_id", "profile_attribute_id"], name: "index_breakdown_attr_reqs_unique", unique: true
    t.index ["breakdown_id"], name: "index_breakdown_attr_reqs_on_breakdown"
    t.index ["profile_attribute_id"], name: "index_breakdown_attribute_requirements_on_profile_attribute_id"
  end

  create_table "breakdown_criteria", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "breakdown_id", null: false
    t.datetime "created_at", null: false
    t.string "gender_presentation"
    t.boolean "local_hire_required", default: false, null: false
    t.integer "portrayal_age_max"
    t.integer "portrayal_age_min"
    t.string "required_location"
    t.boolean "travel_provided"
    t.string "union_requirement"
    t.datetime "updated_at", null: false
    t.string "work_authorization"
    t.index ["breakdown_id"], name: "index_breakdown_criteria_on_breakdown_id", unique: true
  end

  create_table "breakdown_skill_requirements", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.uuid "breakdown_id", null: false
    t.datetime "created_at", null: false
    t.string "minimum_proficiency"
    t.text "notes"
    t.string "requirement_level", default: "required", null: false
    t.uuid "skill_id", null: false
    t.datetime "updated_at", null: false
    t.index ["breakdown_id", "skill_id"], name: "index_breakdown_skill_reqs_unique", unique: true
    t.index ["breakdown_id"], name: "index_breakdown_skill_reqs_on_breakdown"
    t.index ["skill_id"], name: "index_breakdown_skill_requirements_on_skill_id"
    t.check_constraint "requirement_level::text = ANY (ARRAY['required'::character varying, 'preferred'::character varying, 'nice_to_have'::character varying]::text[])", name: "breakdown_skill_reqs_level_check"
  end

  create_table "breakdowns", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "audition_required", default: true, null: false
    t.string "billing"
    t.string "character_name", null: false
    t.datetime "closed_at"
    t.text "compensation_details"
    t.datetime "created_at", null: false
    t.uuid "created_by_user_id", null: false
    t.text "description", null: false
    t.text "location_details"
    t.integer "number_of_roles", default: 1, null: false
    t.uuid "project_id", null: false
    t.datetime "published_at"
    t.string "role_type"
    t.string "status", default: "draft", null: false
    t.datetime "submission_deadline"
    t.datetime "updated_at", null: false
    t.string "visibility", default: "representatives_only", null: false
    t.date "work_end_date"
    t.date "work_start_date"
    t.index ["created_by_user_id"], name: "index_breakdowns_on_created_by_user_id"
    t.index ["project_id"], name: "index_breakdowns_on_project_id"
    t.index ["status"], name: "index_breakdowns_on_status"
    t.index ["visibility"], name: "index_breakdowns_on_visibility"
    t.check_constraint "visibility::text = ANY (ARRAY['representatives_only'::character varying, 'public'::character varying, 'private'::character varying]::text[])", name: "breakdowns_visibility_check"
  end

  create_table "casting_professional_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "professional_title"
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_casting_professional_profiles_on_user_id", unique: true
  end

  create_table "divisions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.boolean "active", default: true, null: false
    t.datetime "created_at", null: false
    t.text "description"
    t.string "name", null: false
    t.uuid "organization_id", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_id", "slug"], name: "index_divisions_on_organization_id_and_slug", unique: true
    t.index ["organization_id"], name: "index_divisions_on_organization_id"
  end

  create_table "organization_memberships", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "accepted_at"
    t.datetime "created_at", null: false
    t.date "ended_on"
    t.datetime "invited_at"
    t.string "job_title"
    t.string "membership_role", null: false
    t.uuid "organization_id", null: false
    t.date "started_on"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["organization_id", "user_id", "membership_role", "started_on"], name: "index_org_memberships_on_org_user_role_started", unique: true
    t.index ["organization_id"], name: "index_organization_memberships_on_organization_id"
    t.index ["status"], name: "index_organization_memberships_on_status"
    t.index ["user_id"], name: "index_organization_memberships_on_user_id"
  end

  create_table "organizations", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "address_line_1"
    t.string "address_line_2"
    t.string "city"
    t.string "country_code"
    t.datetime "created_at", null: false
    t.citext "email"
    t.string "name", null: false
    t.string "organization_type", null: false
    t.string "phone_number"
    t.string "postal_code"
    t.string "state_region"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.string "website_url"
    t.index ["organization_type"], name: "index_organizations_on_organization_type"
    t.index ["status"], name: "index_organizations_on_status"
    t.check_constraint "organization_type::text = ANY (ARRAY['casting_office'::character varying, 'agency'::character varying, 'management_company'::character varying]::text[])", name: "organizations_type_check"
  end

  create_table "profile_attributes", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.boolean "is_sensitive", default: false, null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_profile_attributes_on_slug", unique: true
  end

  create_table "project_casting_team_members", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.uuid "organization_membership_id", null: false
    t.jsonb "permissions", default: {}, null: false
    t.uuid "project_id", null: false
    t.string "project_role", null: false
    t.datetime "updated_at", null: false
    t.index ["organization_membership_id"], name: "index_project_team_on_membership"
    t.index ["project_id", "organization_membership_id"], name: "index_project_team_unique", unique: true
    t.index ["project_id"], name: "index_project_casting_team_members_on_project_id"
  end

  create_table "projects", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "archived_at"
    t.uuid "casting_office_id"
    t.boolean "confidential", default: false, null: false
    t.datetime "created_at", null: false
    t.uuid "created_by_user_id", null: false
    t.text "description"
    t.string "location_summary"
    t.string "name", null: false
    t.string "production_company_name"
    t.string "project_type", null: false
    t.datetime "published_at"
    t.date "shoot_end_date"
    t.date "shoot_start_date"
    t.string "status", default: "draft", null: false
    t.string "union_status"
    t.datetime "updated_at", null: false
    t.index ["casting_office_id"], name: "index_projects_on_casting_office_id"
    t.index ["created_by_user_id"], name: "index_projects_on_created_by_user_id"
    t.index ["project_type"], name: "index_projects_on_project_type"
    t.index ["status"], name: "index_projects_on_status"
  end

  create_table "representative_profiles", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "representative_type", null: false
    t.datetime "updated_at", null: false
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_representative_profiles_on_user_id", unique: true
    t.check_constraint "representative_type::text = ANY (ARRAY['agent'::character varying, 'manager'::character varying]::text[])", name: "representative_profiles_type_check"
  end

  create_table "sessions", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "ip_address"
    t.datetime "updated_at", null: false
    t.string "user_agent"
    t.uuid "user_id", null: false
    t.index ["user_id"], name: "index_sessions_on_user_id"
  end

  create_table "skills", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.string "category"
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.string "slug", null: false
    t.datetime "updated_at", null: false
    t.index ["slug"], name: "index_skills_on_slug", unique: true
  end

  create_table "users", id: :uuid, default: -> { "gen_random_uuid()" }, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.citext "email", null: false
    t.string "first_name", null: false
    t.string "last_name", null: false
    t.datetime "last_signed_in_at"
    t.string "password_digest", null: false
    t.string "phone_number"
    t.string "status", default: "active", null: false
    t.datetime "updated_at", null: false
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["status"], name: "index_users_on_status"
  end

  add_foreign_key "actor_attributes", "actor_profiles"
  add_foreign_key "actor_attributes", "profile_attributes"
  add_foreign_key "actor_profiles", "users"
  add_foreign_key "actor_representation_contacts", "actor_representation_divisions"
  add_foreign_key "actor_representation_contacts", "representative_profiles"
  add_foreign_key "actor_representation_divisions", "actor_representations"
  add_foreign_key "actor_representation_divisions", "divisions"
  add_foreign_key "actor_representations", "actor_profiles"
  add_foreign_key "actor_representations", "organizations"
  add_foreign_key "actor_representations", "users", column: "invited_by_user_id"
  add_foreign_key "actor_skills", "actor_profiles"
  add_foreign_key "actor_skills", "skills"
  add_foreign_key "breakdown_access_grants", "breakdowns"
  add_foreign_key "breakdown_attribute_requirements", "breakdowns"
  add_foreign_key "breakdown_attribute_requirements", "profile_attributes"
  add_foreign_key "breakdown_criteria", "breakdowns"
  add_foreign_key "breakdown_skill_requirements", "breakdowns"
  add_foreign_key "breakdown_skill_requirements", "skills"
  add_foreign_key "breakdowns", "projects"
  add_foreign_key "breakdowns", "users", column: "created_by_user_id"
  add_foreign_key "casting_professional_profiles", "users"
  add_foreign_key "divisions", "organizations"
  add_foreign_key "organization_memberships", "organizations"
  add_foreign_key "organization_memberships", "users"
  add_foreign_key "project_casting_team_members", "organization_memberships"
  add_foreign_key "project_casting_team_members", "projects"
  add_foreign_key "projects", "organizations", column: "casting_office_id"
  add_foreign_key "projects", "users", column: "created_by_user_id"
  add_foreign_key "representative_profiles", "users"
  add_foreign_key "sessions", "users"
end
