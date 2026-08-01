class CreateActorRepresentations < ActiveRecord::Migration[8.1]
  def change
    create_table :actor_representations, id: :uuid do |t|
      t.references :actor_profile, null: false, foreign_key: true, type: :uuid
      t.references :organization, null: false, foreign_key: true, type: :uuid
      t.string :status, null: false, default: "pending"
      t.date :started_on
      t.date :ended_on
      t.boolean :exclusive, null: false, default: false
      t.text :notes
      t.references :invited_by_user, foreign_key: { to_table: :users }, type: :uuid
      t.datetime :confirmed_at

      t.timestamps
    end

    add_index :actor_representations, :status
    add_index :actor_representations,
      [ :actor_profile_id, :organization_id ],
      name: "index_actor_reps_on_actor_and_org"

    create_table :actor_representation_divisions, id: :uuid do |t|
      t.references :actor_representation, null: false, foreign_key: true, type: :uuid,
        index: { name: "index_actor_rep_divisions_on_representation" }
      t.references :division, null: false, foreign_key: true, type: :uuid
      t.string :status, null: false, default: "active"
      t.date :started_on
      t.date :ended_on

      t.timestamps
    end

    add_index :actor_representation_divisions,
      [ :actor_representation_id, :division_id, :started_on ],
      unique: true,
      name: "index_actor_rep_divisions_unique"

    create_table :actor_representation_contacts, id: :uuid do |t|
      t.references :actor_representation_division, null: false, foreign_key: true, type: :uuid,
        index: { name: "index_actor_rep_contacts_on_division" }
      t.references :representative_profile, null: false, foreign_key: true, type: :uuid,
        index: { name: "index_actor_rep_contacts_on_rep" }
      t.boolean :is_primary, null: false, default: false
      t.date :started_on
      t.date :ended_on

      t.timestamps
    end
  end
end
