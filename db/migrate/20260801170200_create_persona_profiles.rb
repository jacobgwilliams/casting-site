class CreatePersonaProfiles < ActiveRecord::Migration[8.1]
  def change
    create_table :actor_profiles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.string :professional_name
      t.string :union_status
      t.string :primary_location
      t.string :timezone
      t.string :profile_status, null: false, default: "draft"

      t.timestamps
    end

    add_index :actor_profiles, :profile_status

    create_table :casting_professional_profiles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.string :professional_title

      t.timestamps
    end

    create_table :representative_profiles, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid, index: { unique: true }
      t.string :representative_type, null: false

      t.timestamps
    end

    add_check_constraint :representative_profiles,
      "representative_type IN ('agent', 'manager')",
      name: "representative_profiles_type_check"
  end
end
