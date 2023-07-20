
RSpec.describe SiweAuthenticator do
  describe '#after_authenticate' do
    let(:ethaddress) { '0x0123' }
    let(:user) { Fabricate(:user) }
    let(:associated_accounts) { [Fabricate(:user_associated_account_siwe, user_id: user.id, provider_uid: ethaddress, info: {
      'name' => ethaddress,
    })] }
    it 'refreshes the score if the user is associated with an account' do
      UserAssociatedAccount.stubs(:where).returns(associated_accounts)
      DiscourseGitcoinPassport::Passport.stubs(:refresh_passport_score).returns(42)

      auth_token = { provider: 'provider_name', uid: ethaddress, info: {
        name: ethaddress
      } }

      siwe_authenticator = SiweAuthenticator.new
      siwe_authenticator.after_authenticate(auth_token)

      expect(user.reload.passport_score).to eq(42)
    end

    it 'does not refresh the score if the user is not associated with an account' do
      DiscourseGitcoinPassport::Passport.stubs(:refresh_passport_score).returns(42)

      auth_token = { provider: 'provider_name', uid: ethaddress, info: {
        name: ethaddress
      } }
      siwe_authenticator = SiweAuthenticator.new
      siwe_authenticator.after_authenticate(auth_token)
      DiscourseGitcoinPassport::Passport.expects(:refresh_passport_score).never
    end
  end

  describe '#after_create_account' do
    let(:ethaddress) { '0x0123' }
    let(:user) { Fabricate(:user) }
    let(:associated_accounts) { [Fabricate(:user_associated_account_siwe, user_id: user.id, provider_uid: ethaddress, info: {
      'name' => ethaddress,
    })] }

    it 'updates the passport score if Gitcoin Passport is enabled' do
      SiteSetting.gitcoin_passport_enabled = true
      UserAssociatedAccount.stubs(:where).returns(associated_accounts)

      auth = Auth::Result.new
      auth.extra_data = { uid: '0x0123', provider: 'siwe' }

      DiscourseGitcoinPassport::Passport.stubs(:score).returns(21)
      siwe_authenticator = SiweAuthenticator.new
      siwe_authenticator.after_create_account(user, auth)

      expect(user.reload.passport_score).to eq(21)
    end

    it 'does not update the passport score if Gitcoin Passport is disabled' do
      SiteSetting.gitcoin_passport_enabled = false
      UserAssociatedAccount.stubs(:where).returns(associated_accounts)

      auth = Auth::Result.new
      auth.extra_data = { uid: '0x0123', provider: 'siwe' }

      siwe_authenticator = SiweAuthenticator.new
      siwe_authenticator.after_create_account(user, auth)

      expect(user.reload.passport_score).to eq(nil)

    end
  end
end
