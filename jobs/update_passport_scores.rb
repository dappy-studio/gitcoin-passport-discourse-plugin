# frozen_string_literal: true

module Jobs
    class GitcoinPassportUpdateAll < Jobs::Scheduled
      every 12.hours
  
      def execute(_args)
        return unless SiteSetting.gitcoin_passport_enabled
        user_ids = UserAssociatedAccount.where(provider_name: "siwe").pluck(:user_id)
        User.where(id: user_ids).each do |user|
            Passport::refresh_passport_score(user)
        end
      end
    end
  end