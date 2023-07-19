
RSpec.describe UserPassportScore do
  describe '#create' do
    it 'ensures that required_score is within the valid range' do
      user = Fabricate(:user) # Create a user for association
      valid_score = 50
      invalid_score = 150
      invalid_score2 = -1
      # Create a valid UserPassportScore instance
      valid_passport_score = UserPassportScore.new(
        required_score: valid_score,
        user: user
      )
      expect(valid_passport_score).to be_valid

      # Create an invalid UserPassportScore instance
      invalid_passport_score = UserPassportScore.new(
        required_score: invalid_score,
        user: user
      )
      expect(invalid_passport_score).not_to be_valid
      expect(invalid_passport_score.errors[:required_score]).to include("must be less than or equal to 100")

      # Create an invalid UserPassportScore instance
      invalid_passport_score2 = UserPassportScore.new(
        required_score: invalid_score2,
        user: user
      )
      expect(invalid_passport_score2).not_to be_valid
      expect(invalid_passport_score2.errors[:required_score]).to include("must be greater than or equal to 0")
    end

    it 'validates uniqueness of user_id and user_action_type' do
      user = Fabricate(:user) # Create a valid user

      existing_score = UserPassportScore.create(user_id: user.id, user_action_type: 1, required_score: 50)

      new_score = UserPassportScore.new(user_id: user.id, user_action_type: 1, required_score: 75)
      expect(new_score).not_to be_valid
      expect(new_score.errors[:user_id]).to include('has already been taken')

      new_score.user_id = user.id + 1
      expect(new_score).to be_valid
    end
  end

end
