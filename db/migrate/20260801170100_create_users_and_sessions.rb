class CreateUsersAndSessions < ActiveRecord::Migration[8.1]
  def change
    create_table :users, id: :uuid do |t|
      t.citext :email, null: false
      t.string :password_digest, null: false
      t.string :first_name, null: false
      t.string :last_name, null: false
      t.string :phone_number
      t.string :status, null: false, default: "active"
      t.datetime :last_signed_in_at

      t.timestamps
    end

    add_index :users, :email, unique: true
    add_index :users, :status

    create_table :sessions, id: :uuid do |t|
      t.references :user, null: false, foreign_key: true, type: :uuid
      t.string :user_agent
      t.string :ip_address

      t.timestamps
    end
  end
end
