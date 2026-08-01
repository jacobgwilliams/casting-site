class CreateProjectsAndBreakdowns < ActiveRecord::Migration[8.1]
  def change
    create_table :projects, id: :uuid do |t|
      t.string :name, null: false
      t.string :project_type, null: false
      t.text :description
      t.string :status, null: false, default: "draft"
      t.references :casting_office, foreign_key: { to_table: :organizations }, type: :uuid
      t.references :created_by_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.string :production_company_name
      t.string :union_status
      t.date :shoot_start_date
      t.date :shoot_end_date
      t.string :location_summary
      t.boolean :confidential, null: false, default: false
      t.datetime :published_at
      t.datetime :archived_at

      t.timestamps
    end

    add_index :projects, :status
    add_index :projects, :project_type

    create_table :project_casting_team_members, id: :uuid do |t|
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.references :organization_membership, null: false, foreign_key: true, type: :uuid,
        index: { name: "index_project_team_on_membership" }
      t.string :project_role, null: false
      t.jsonb :permissions, null: false, default: {}

      t.timestamps
    end

    add_index :project_casting_team_members,
      [ :project_id, :organization_membership_id ],
      unique: true,
      name: "index_project_team_unique"

    create_table :breakdowns, id: :uuid do |t|
      t.references :project, null: false, foreign_key: true, type: :uuid
      t.string :character_name, null: false
      t.text :description, null: false
      t.string :role_type
      t.string :billing
      t.string :status, null: false, default: "draft"
      t.string :visibility, null: false, default: "representatives_only"
      t.integer :number_of_roles, null: false, default: 1
      t.boolean :audition_required, null: false, default: true
      t.datetime :submission_deadline
      t.date :work_start_date
      t.date :work_end_date
      t.text :compensation_details
      t.text :location_details
      t.references :created_by_user, null: false, foreign_key: { to_table: :users }, type: :uuid
      t.datetime :published_at
      t.datetime :closed_at

      t.timestamps
    end

    add_index :breakdowns, :status
    add_index :breakdowns, :visibility
    add_check_constraint :breakdowns,
      "visibility IN ('representatives_only', 'public', 'private')",
      name: "breakdowns_visibility_check"

    create_table :breakdown_criteria, id: :uuid do |t|
      t.references :breakdown, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.integer :portrayal_age_min
      t.integer :portrayal_age_max
      t.string :gender_presentation
      t.string :union_requirement
      t.boolean :local_hire_required, null: false, default: false
      t.string :required_location
      t.boolean :travel_provided
      t.string :work_authorization

      t.timestamps
    end

    create_table :breakdown_access_grants, id: :uuid do |t|
      t.references :breakdown, null: false, foreign_key: true, type: :uuid
      t.string :grantee_type, null: false
      t.uuid :grantee_id, null: false
      t.string :access_level, null: false, default: "view"
      t.datetime :expires_at

      t.timestamps
    end

    add_index :breakdown_access_grants, [ :grantee_type, :grantee_id ]
  end
end
