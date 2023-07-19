class CreateCategoryPassportScoreTable < ActiveRecord::Migration[6.0]
  def change
    create_table :category_passport_scores do |t|
      t.float :required_score, null: false
      t.integer :user_action_type, null: false
      t.references :category, null: false, foreign_key: true

      t.timestamps
    end

    add_index :category_passport_scores, [:user_action_type, :category_id], unique: true, name: "index_category_score_on_action_id_category_id"
  end
end
