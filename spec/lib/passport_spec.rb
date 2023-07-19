RSpec.describe DiscourseGitcoinPassport::Passport do
  describe '.score' do
    it 'returns the score from the Gitcoin API' do
      user_address = '0x1234567890'
      scorer_id = 'scorer123'

      stub_fetch_score_request({
        address: user_address,
        scorer_id: scorer_id
      }.to_json, {
        score: 42
      }.to_json)
      score = DiscourseGitcoinPassport::Passport.score(user_address, scorer_id)

      expect(score).to eq(42)
    end
  end

  describe '.minimum_required_score' do
    context 'when action type is reply' do
      let(:action_type) { UserAction.types[:reply] }
      let(:category_id) { Fabricate(:category).id }
      let(:user_id) { Fabricate(:user).id }

      it 'returns the forum level score when no category or user level score is present' do
        SiteSetting.gitcoin_passport_forum_level_score_to_post = 10.0

        minimum_required_score = DiscourseGitcoinPassport::Passport.minimum_required_score(user_id, category_id, action_type)

        expect(minimum_required_score).to eq(10.0)
      end

      it 'returns the category level score when present and no user level score is present' do
        SiteSetting.gitcoin_passport_forum_level_score_to_post = 10.0
        CategoryPassportScore.create!(category_id: category_id, user_action_type: action_type, required_score: 15.0)

        minimum_required_score = DiscourseGitcoinPassport::Passport.minimum_required_score(user_id, category_id, action_type)

        expect(minimum_required_score).to eq(15.0)
      end

      it 'returns the user level score when present' do
        SiteSetting.gitcoin_passport_forum_level_score_to_post = 10.0
        CategoryPassportScore.create!(category_id: category_id, user_action_type: action_type, required_score: 18.0)
        UserPassportScore.create!(user_id: user_id, user_action_type: action_type, required_score: 20.0)
        minimum_required_score = DiscourseGitcoinPassport::Passport.minimum_required_score(user_id, category_id, action_type)

        expect(minimum_required_score).to eq(20.0)
      end
    end
  end

  describe '.has_minimimum_required_score?' do
    context 'when the minimum required score is 0' do
      let(:action_type) { UserAction.types[:reply] }
      let(:category) { Fabricate(:category) }
      let(:user) { Fabricate(:user) }


      it 'returns true when minimum score is 0 even if there is no ethaddress' do
        DiscourseGitcoinPassport::Passport.stubs(:minimum_required_score).returns(0)
        has_minimimum_required_score = DiscourseGitcoinPassport::Passport.has_minimimum_required_score?(user, category, action_type)

        expect(has_minimimum_required_score).to eq(true)
      end
    end

    context 'when the minimum required score is greater than 0' do
      let(:action_type) { UserAction.types[:reply] }
      let(:category) { Fabricate(:category) }
      let(:user) { Fabricate(:user) }

      it 'returns false when there is a minimum score required and no ethaddress' do
        DiscourseGitcoinPassport::Passport.stubs(:minimum_required_score).returns(24)
        has_minimimum_required_score = DiscourseGitcoinPassport::Passport.has_minimimum_required_score?(user, category, action_type)

        expect(has_minimimum_required_score).to eq(false)
      end


      it 'returns true when there is an ethaddress and the passport score is higher than the required score' do
        DiscourseGitcoinPassport::Passport.stubs(:minimum_required_score).returns(24)
        DiscourseGitcoinPassport::Passport.stubs(:fetch_score).returns(41)
        UserAssociatedAccount.create!(user_id: user.id, provider_name: "siwe", provider_uid: "0x1234567890", info: {
          name: "0x1234567890"
        })

        has_minimimum_required_score = DiscourseGitcoinPassport::Passport.has_minimimum_required_score?(user, category, action_type)

        expect(has_minimimum_required_score).to eq(true)
      end

      it 'returns false when there is an ethaddress and the passport score is not higher than the required score' do
        DiscourseGitcoinPassport::Passport.stubs(:minimum_required_score).returns(24)
        DiscourseGitcoinPassport::Passport.stubs(:fetch_score).returns(13)

        UserAssociatedAccount.create!(user_id: user.id, provider_name: "siwe", provider_uid: "0x1234567890", info: {
          name: "0x1234567890"
        })
        has_minimimum_required_score = DiscourseGitcoinPassport::Passport.has_minimimum_required_score?(user, category, action_type)

        expect(has_minimimum_required_score).to eq(false)
      end
    end
  end

  describe '.available_badges_to_claim' do
    let(:unique_humanity_badge_group) { Fabricate(:unique_humanity_badge_group) }
    let(:silver_badge_type_id) {BadgeType.where(name: 'Silver').first.id}
    let(:gold_badge_type_id) {BadgeType.where(name: 'Gold').first.id}
    let(:bronze_badge_type_id) {BadgeType.where(name: 'Bronze').first.id}


    let(:badge_silver) { Fabricate(:unique_humanity_silver_badge, badge_grouping_id: unique_humanity_badge_group.id, badge_type_id: silver_badge_type_id) }
    let(:badge_gold) { Fabricate(:unique_humanity_gold_badge, badge_grouping_id: unique_humanity_badge_group.id, badge_type_id: gold_badge_type_id) }
    let(:badge_bronze) { Fabricate(:unique_humanity_bronze_badge, badge_grouping_id: unique_humanity_badge_group.id, badge_type_id: bronze_badge_type_id) }

    let(:badges) { [badge_gold, badge_silver, badge_bronze] }
    let(:passport_score) { 10.0 }
    let(:user) { Fabricate(:user) }

    SiteSetting.gitcoin_passport_required_to_get_unique_humanity_gold_badge = 15.0
    SiteSetting.gitcoin_passport_required_to_get_unique_humanity_silver_badge = 10.0
    SiteSetting.gitcoin_passport_required_to_get_unique_humanity_bronze_badge = 5.0

    it 'returns the available badges to claim' do
      available_badges = DiscourseGitcoinPassport::Passport.available_badges_to_claim(badges, passport_score, user)
      expect(available_badges).to eq([badge_silver, badge_bronze])
    end

    it 'does not include badges already claimed' do
      UserBadge.create!(badge_id: badge_bronze[:id], user_id: user[:id], granted_by: Discourse.system_user, granted_at: Time.now,)
      available_badges = DiscourseGitcoinPassport::Passport.available_badges_to_claim(badges, passport_score, user)

      expect(available_badges).to eq([badge_silver])
    end

    it 'does not include badges if the passport score is below the threshold' do

      available_badges = DiscourseGitcoinPassport::Passport.available_badges_to_claim(badges, 3.0, user)

      expect(available_badges).to eq([])
    end
  end

  describe '.grant_badges' do
    let(:badge1) { Fabricate(:badge) }
    let(:badge2) { Fabricate(:badge) }
    let(:badge3) { Fabricate(:badge) }
    fab!(:user) { Fabricate(:user) }

    it 'grants badges to the user' do
      badges = [badge1, badge2, badge3]

      DiscourseGitcoinPassport::Passport.grant_badges(badges, user)


      badges.each do |badge|
        expect(UserBadge.where(badge_id: badge[:id], user_id: user[:id]).count).to eq(1)
      end
    end
  end

  describe '.refresh_passport_score' do
    let(:user_address) { '0x1234567890' }
    let(:scorer_id) { 0 }
    let(:user) { Fabricate(:user) }
    let(:user_with_associated_siwe_account) { Fabricate(:user) }

    before do
      DiscourseGitcoinPassport::Passport.stubs(:score).returns(92)
    end

    it 'does not update the passport score for the user if wallet is not connected' do
      expect{ DiscourseGitcoinPassport::Passport.refresh_passport_score(user) }.to raise_error(Discourse::InvalidAccess)
    end

    it 'updates the passport score for the user if wallet is connected' do
      acc = UserAssociatedAccount.where(user_id: user_with_associated_siwe_account.id, provider_name: "siwe").first
      if acc
        acc.info = {name: user_address}
        acc.save!
      else
        UserAssociatedAccount.create!(user_id: user_with_associated_siwe_account.id, provider_name: "siwe", provider_uid: user_address, info: {
          name: user_address
        })
      end
      score = DiscourseGitcoinPassport::Passport.refresh_passport_score(user_with_associated_siwe_account)

      expect(score).to eq(92)
      expect(User.find(user_with_associated_siwe_account.id).passport_score).to eq(92)
      expect(User.find(user_with_associated_siwe_account.id).passport_score_last_update).to be_present
    end
  end
end
