class CategoryPassportScore < ActiveRecord::Base
  belongs_to :category

  validates :required_score,
  numericality: {
    greater_than_or_equal_to: 0,
    less_than_or_equal_to: 100,
    allow_nil: false,
  }
  validates :category_id, uniqueness: { scope: :user_action_type }

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
