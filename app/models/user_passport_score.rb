class UserPassportScore < ActiveRecord::Base
  belongs_to :user

  validates :required_score,
  numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    allow_nil: false,
  }
  validates :user_id, uniqueness: { scope: :user_action_type }

end



# == Schema Information
#
# Table name: user_passport_scores
#
#  id                     :integer           not null, primary key
#  required_score         :float            not null
#  user_id                :integer           not null
#  user_action_type       :integer           not null
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_user_passport_score_on_action_id_user_id                           (user_action_type, user_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (user_id => user.id)
#
