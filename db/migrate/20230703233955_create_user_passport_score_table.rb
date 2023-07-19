class CreateUserPassportScoreTable < ActiveRecord::Migration[6.0]
  def change
    create_table :user_passport_scores do |t|
      t.float :required_score, null: false
      t.integer :user_action_type, null: false
      t.references :user, null: false, foreign_key: true

      t.timestamps
    end

    add_index :user_passport_scores, [:user_action_type, :user_id], unique: true
  end
end
