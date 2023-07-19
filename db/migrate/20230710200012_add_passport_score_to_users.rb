class AddPassportScoreToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :passport_score, :float
    add_column :users, :passport_score_last_update, :datetime
  end
end
