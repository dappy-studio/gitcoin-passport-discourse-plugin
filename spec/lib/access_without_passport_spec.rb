require 'date'

RSpec.describe DiscourseGitcoinPassport::AccessWithoutPassport do
  before { freeze_time DateTime.parse("2023-11-10") }

  describe '#access_expiration' do
    context 'when today is after the last date to connect wallet for existing users' do
      before do
        SiteSetting.gitcoin_passport_enabled = true
        SiteSetting.gitcoin_passport_last_date_to_connect_wallet_for_existing_users = '2023-07-01'
      end
      it 'returns true' do
        expect(DiscourseGitcoinPassport::AccessWithoutPassport.expired?).to eq(true)
      end
    end

    context 'when today is before the last date to connect wallet' do
      before do
        SiteSetting.gitcoin_passport_enabled = true
        SiteSetting.gitcoin_passport_last_date_to_connect_wallet_for_existing_users = '2023-12-12'
      end

      it 'returns false' do
        expect(DiscourseGitcoinPassport::AccessWithoutPassport.expired?).to eq(false)
      end
    end

    context 'when gitcoin passport is not enabled' do
      before do
        SiteSetting.gitcoin_passport_enabled = false
        SiteSetting.gitcoin_passport_last_date_to_connect_wallet_for_existing_users = '2023-07-01'
      end

      it 'returns false' do
        expect(DiscourseGitcoinPassport::AccessWithoutPassport.expired?).to eq(false)
      end
    end
  end
end
