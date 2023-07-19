# frozen_string_literal: true

require "rails_helper"

RSpec.describe TopicGuardian do
  describe '#can_create_post_on_topic?' do
    let(:user) { Fabricate(:user) }
    let(:category) { Fabricate(:category) }

    before do
      SiteSetting.gitcoin_passport_enabled = true
    end

    it 'returns false when Gitcoin Passport access has expired and user does not have the minimum required score' do
      topic = Fabricate(:topic, category: category)

      DiscourseGitcoinPassport::AccessWithoutPassport.stubs(:expired?).returns(true)
      DiscourseGitcoinPassport::Passport.stubs(:has_minimimum_required_score?).returns(false)

      result = Guardian.new(user).can_create_post_on_topic?(topic)

      expect(result).to eq(false)
    end

    it 'calls the original method when Gitcoin Passport access has not expired or user has the minimum required score' do
      topic = Fabricate(:topic, category: category)

      DiscourseGitcoinPassport::AccessWithoutPassport.stubs(:expired?).returns(false)
      DiscourseGitcoinPassport::Passport.stubs(:has_minimimum_required_score?).returns(true)

      result = Guardian.new(user).can_create_post_on_topic?(topic)

      expect(result).to eq(true)
    end
  end

  describe '#can_create_topic_on_category?' do
    let(:user) { Fabricate(:user) }
    let(:category) { Fabricate(:category) }

    before do
      SiteSetting.gitcoin_passport_enabled = true
    end

    it 'returns false when Gitcoin Passport access has expired and user does not have the minimum required score' do

      DiscourseGitcoinPassport::AccessWithoutPassport.stubs(:expired?).returns(true)
      DiscourseGitcoinPassport::Passport.stubs(:has_minimimum_required_score?).returns(false)

      result = Guardian.new(user).can_create_topic_on_category?(category)

      expect(result).to eq(false)
    end

    it 'calls the original method when Gitcoin Passport access has not expired or user has the minimum required score' do

      DiscourseGitcoinPassport::AccessWithoutPassport.stubs(:expired?).returns(false)
      DiscourseGitcoinPassport::Passport.stubs(:has_minimimum_required_score?).returns(true)

      result = Guardian.new(user).can_create_topic_on_category?(category)

      expect(result).to eq(true)
    end
  end
end
