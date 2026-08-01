class CreateSkillsAndAttributes < ActiveRecord::Migration[8.1]
  def change
    create_table :skills, id: :uuid do |t|
      t.string :name, null: false
      t.string :category
      t.string :slug, null: false

      t.timestamps
    end

    add_index :skills, :slug, unique: true

    create_table :actor_skills, id: :uuid do |t|
      t.references :actor_profile, null: false, foreign_key: true, type: :uuid
      t.references :skill, null: false, foreign_key: true, type: :uuid
      t.string :proficiency
      t.integer :years_experience
      t.boolean :verified, null: false, default: false
      t.text :notes

      t.timestamps
    end

    add_index :actor_skills, [ :actor_profile_id, :skill_id ], unique: true

    create_table :breakdown_skill_requirements, id: :uuid do |t|
      t.references :breakdown, null: false, foreign_key: true, type: :uuid,
        index: { name: "index_breakdown_skill_reqs_on_breakdown" }
      t.references :skill, null: false, foreign_key: true, type: :uuid
      t.string :requirement_level, null: false, default: "required"
      t.string :minimum_proficiency
      t.text :notes

      t.timestamps
    end

    add_index :breakdown_skill_requirements,
      [ :breakdown_id, :skill_id ],
      unique: true,
      name: "index_breakdown_skill_reqs_unique"
    add_check_constraint :breakdown_skill_requirements,
      "requirement_level IN ('required', 'preferred', 'nice_to_have')",
      name: "breakdown_skill_reqs_level_check"

    # Named profile_attributes (not attributes) to avoid clashing with
    # ActiveRecord's built-in attributes API.
    create_table :profile_attributes, id: :uuid do |t|
      t.string :name, null: false
      t.string :category
      t.string :slug, null: false
      t.boolean :is_sensitive, null: false, default: false

      t.timestamps
    end

    add_index :profile_attributes, :slug, unique: true

    create_table :actor_attributes, id: :uuid do |t|
      t.references :actor_profile, null: false, foreign_key: true, type: :uuid
      t.references :profile_attribute, null: false, foreign_key: true, type: :uuid
      t.string :visibility, null: false, default: "private"
      t.boolean :verified, null: false, default: false

      t.timestamps
    end

    add_index :actor_attributes, [ :actor_profile_id, :profile_attribute_id ],
      unique: true,
      name: "index_actor_attributes_unique"

    create_table :breakdown_attribute_requirements, id: :uuid do |t|
      t.references :breakdown, null: false, foreign_key: true, type: :uuid,
        index: { name: "index_breakdown_attr_reqs_on_breakdown" }
      t.references :profile_attribute, null: false, foreign_key: true, type: :uuid
      t.string :requirement_level, null: false, default: "required"
      t.text :context

      t.timestamps
    end

    add_index :breakdown_attribute_requirements,
      [ :breakdown_id, :profile_attribute_id ],
      unique: true,
      name: "index_breakdown_attr_reqs_unique"
  end
end
