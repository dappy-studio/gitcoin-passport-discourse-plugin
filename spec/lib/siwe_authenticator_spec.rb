
RSpec.describe SiweAuthenticator do
  describe '#after_authenticate' do
    it 'refreshes the score if the user is associated with an account' do
      user = User.create!(username: 'username', email: 'bob@m.co', passport_score: 1, passport_score_last_update: Time.now)
      association = UserAssociatedAccount.create!(user_id: user.id, provider_name: 'provider_name', provider_uid: 'provider_uid')
      auth_token = { provider: 'provider_name', uid: 'provider_uid', info: {
        name: 'provider_uid'
      } }

      DiscourseGitcoinPassport::Passport.stubs(:refresh_passport_score).returns(42)
      siwe_authenticator = SiweAuthenticator.new
      siwe_authenticator.after_authenticate(auth_token)

      expect(user.reload.passport_score).to eq(42)
    end

    it 'does not refresh the score if the user is not associated with an account' do
      auth_token = { provider: 'provider_name', uid: 'provider_uid', info: {
        name: 'provider_uid'
      } }
      DiscourseGitcoinPassport::Passport.stubs(:refresh_passport_score).returns(42)
      siwe_authenticator = SiweAuthenticator.new
      siwe_authenticator.after_authenticate(auth_token)
      DiscourseGitcoinPassport::Passport.expects(:refresh_passport_score).never
    end
  end

  describe '#after_create_account' do

    it 'updates the passport score if Gitcoin Passport is enabled' do
      user = Fabricate(:user)
      user_associated_account = UserAssociatedAccount.create!(provider_name: 'siwe', provider_uid: '0x0123')
      auth = Auth::Result.new
      auth.extra_data = { uid: '0x0123', provider: 'siwe' }
      SiteSetting.gitcoin_passport_enabled = true

      DiscourseGitcoinPassport::Passport.stubs(:score).returns(21)
      siwe_authenticator = SiweAuthenticator.new
      siwe_authenticator.after_create_account(user, auth)

      expect(user.reload.passport_score).to eq(21)
    end

    it 'does not update the passport score if Gitcoin Passport is disabled' do
      user = Fabricate(:user)
      user_associated_account = UserAssociatedAccount.create!(provider_name: 'siwe', provider_uid: '0x0123')
      auth = Auth::Result.new
      auth.extra_data = { uid: '0x0123', provider: 'siwe' }
      SiteSetting.gitcoin_passport_enabled = false

      siwe_authenticator = SiweAuthenticator.new
      siwe_authenticator.after_create_account(user, auth)

      expect(user.reload.passport_score).to eq(nil)

    end
  end
end
