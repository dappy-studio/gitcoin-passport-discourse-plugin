class CategoryPassportScore < ActiveRecord::Base
  belongs_to :category

  validate :validate_required_score
  validates :category_id, uniqueness: { scope: :user_action_type }

  def validate_required_score
    if self.required_score < 0 || self.required_score > 100
      errors.add(:required_score, I18n.t("errors.score_not_between_required_range"))
    end
  end
end



# == Schema Information
#
# Table name: category_passport_scores
#
#  id                    :integer           not null, primary key
#  required_score        :float            not null
#  category_id           :integer           not null
#  user_action_type      :integer           not null
#  created_at            :datetime         not null
#  updated_at            :datetime         not null
#
# Indexes
#
#  index_category_score_on_action_id_category_id                      (user_action_type, category_id) UNIQUE
#
# Foreign Keys
#
#  fk_rails_...  (category_id => category.id)
#
