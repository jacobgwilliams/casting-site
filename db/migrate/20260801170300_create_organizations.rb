class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations, id: :uuid do |t|
      t.string :name, null: false
      t.string :organization_type, null: false
      t.string :status, null: false, default: "active"
      t.string :website_url
      t.string :phone_number
      t.citext :email
      t.string :address_line_1
      t.string :address_line_2
      t.string :city
      t.string :state_region
      t.string :postal_code
      t.string :country_code

      t.timestamps
    end

    add_index :organizations, :organization_type
    add_index :organizations, :status
    add_check_constraint :organizations,
      "organization_type IN ('casting_office', 'agency', 'management_company')",
      name: "organizations_type_check"

    create_table :organization_memberships, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :membership_role, null: false
      t.string :job_title
      t.string :status, null: false, default: "active"
      t.date :started_on
      t.date :ended_on
      t.datetime :invited_at
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :organization_memberships,
      [ :organization_id, :user_id, :membership_role, :started_on ],
      unique: true,
      name: "index_org_memberships_on_org_user_role_started"
    add_index :organization_memberships, :status

    create_table :divisions, id: :uuid do |t|
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :name, null: false
      t.string :slug, null: false
      t.text :description
      t.boolean :active, null: false, default: true

      t.timestamps
    end

    add_index :divisions, [ :organization_id, :slug ], unique: true
  end
end
