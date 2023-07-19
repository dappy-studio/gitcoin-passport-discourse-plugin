
RSpec.describe CategoryPassportScore do
  describe '#create' do
    it 'ensures that required_score is within the valid range' do
      category = Fabricate(:category) # Create a category for association
      valid_score = 50
      invalid_score = 150
      invalid_score2 = -1
      # Create a valid CategoryPassportScore instance
      valid_passport_score = CategoryPassportScore.new(
        required_score: valid_score,
        category: category
      )
      expect(valid_passport_score).to be_valid

      # Create an invalid CategoryPassportScore instance
      invalid_passport_score = CategoryPassportScore.new(
        required_score: invalid_score,
        category: category
      )
      expect(invalid_passport_score).not_to be_valid
      expect(invalid_passport_score.errors[:required_score]).to include("must be less than or equal to 100")

      # Create an invalid CategoryPassportScore instance
      invalid_passport_score2 = CategoryPassportScore.new(
        required_score: invalid_score2,
        category: category
      )
      expect(invalid_passport_score2).not_to be_valid
      expect(invalid_passport_score2.errors[:required_score]).to include("must be greater than or equal to 0")
    end

    it 'validates uniqueness of category_id and user_action_type' do
      category = Fabricate(:category) # Create a valid category

      existing_score = CategoryPassportScore.create(category_id: category.id, user_action_type: 1, required_score: 50)

      new_score = CategoryPassportScore.new(category_id: category.id, user_action_type: 1, required_score: 75)
      expect(new_score).not_to be_valid
      expect(new_score.errors[:category_id]).to include('has already been taken')

      new_score.category_id = category.id + 1
      expect(new_score).to be_valid
    end
  end

end
