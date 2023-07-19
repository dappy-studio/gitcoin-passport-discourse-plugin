require 'date'


class DiscourseGitcoinPassport::AccessWithoutPassport
  def self.expired?
    if SiteSetting.gitcoin_passport_enabled
      passed_expiration_date = Date.parse(SiteSetting.gitcoin_passport_last_date_to_connect_wallet_for_existing_users) < Date.today
      if passed_expiration_date
        return true
      end
    end
    return false
  end

  def self.already_has_passport?(user)
    if SiteSetting.gitcoin_passport_enabled
      siwe_account = user.associated_accounts.find { |account| account[:name] == "siwe" }
      if siwe_account
        return true
      end
    end
    return false
  end
end
