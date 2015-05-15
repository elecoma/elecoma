# This migration comes from comable (originally 20140120032559)
class CreateComableUsers < ActiveRecord::Migration
  def change
    create_table :comable_users do |t|
      ## Database authenticatable
      t.string :email, null: false
      t.string :role, null: false
      t.string :encrypted_password

      ## Recoverable
      t.string :reset_password_token
      t.datetime :reset_password_sent_at

      ## Rememberable
      t.datetime :remember_created_at

      ## Trackable
      t.integer :sign_in_count, default: 0, null: false
      t.datetime :current_sign_in_at
      t.datetime :last_sign_in_at
      t.string :current_sign_in_ip
      t.string :last_sign_in_ip

      ## Confirmable
      # t.string :confirmation_token
      # t.datetime :confirmed_at
      # t.datetime :confirmation_sent_at
      # t.string :unconfirmed_email # Only if using reconfirmable

      ## Lockable
      # t.integer :failed_attempts, default: 0, null: false # Only if lock strategy is :failed_attempts
      # t.string :unlock_token # Only if unlock strategy is :email or :both
      # t.datetime :locked_at

      ## Others
      t.references :bill_address
      t.references :ship_address
    end

    add_index :comable_users, :email, unique: true
    add_index :comable_users, :reset_password_token, unique: true
    # add_index :comable_users, :confirmation_token, unique: true
    # add_index :comable_users, :unlock_token, unique: true
  end
end
