class UserPassportScore < ActiveRecord::Base
  belongs_to :user

  validate :validate_required_score
  validates :user_id, uniqueness: { scope: :user_action_type }

  def validate_required_score
    if self.required_score < 0 || self.required_score > 100
      errors.add(:required_score, I18n.t("errors.score_not_between_required_range"))
    end
  end
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
