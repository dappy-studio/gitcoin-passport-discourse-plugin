

# frozen_string_literal: true

require "rails_helper"

describe DiscourseGitcoinPassport do
  before do
    SiteSetting.gitcoin_passport_enabled = true
  end
  describe "current_user_serializer#ethaddress" do
    context "when no associated accounts exist" do
      let(:no_associated_account) { Fabricate(:user) }
      let(:serializer) { CurrentUserSerializer.new(no_associated_account, scope: Guardian.new(no_associated_account)) }
      it "returns nil" do
        expect(serializer.ethaddress).to eq(nil)
      end
    end

    context "when associated accounts exists without the siwe account" do
      let(:associated_account_without_siwe) { Fabricate(:user) }
      let(:serializer) { CurrentUserSerializer.new(associated_account_without_siwe, scope: Guardian.new(associated_account_without_siwe)) }

      before do
        UserAssociatedAccount.create!(user_id: associated_account_without_siwe.id, provider_name: "github", provider_uid: "adityachakra16", info: {
          name: "adityachakra16"
        })
      end

      it "returns nil" do
        expect(serializer.ethaddress).to eq(nil)
      end
    end

    context "when associated accounts exists with the siwe account" do
      let(:user) { Fabricate(:user) }
      let(:serializer) { CurrentUserSerializer.new(user, scope: Guardian.new(user)) }

      before do
        UserAssociatedAccount.create!(user_id: user.id, provider_name: "siwe", provider_uid: "0x1234567890", info: {
          name: "0x1234567890"
        })
      end

      it "returns ethaddress" do
        expect(serializer.ethaddress).to eq("0x1234567890")
      end
    end
  end

  describe "current_user_serializer#passport_score" do
    context "when passport score exists for user" do
      let(:passport_score_exists) { Fabricate(:user, passport_score: 10) }
      let(:serializer) { CurrentUserSerializer.new(passport_score_exists, scope: Guardian.new(passport_score_exists)) }

      it "returns passport score" do
        expect(serializer.passport_score).to eq(10.0)
      end
    end

    context "when passport score does not exist for user" do
      let(:user) { Fabricate(:user) }
      let(:serializer) { CurrentUserSerializer.new(user, scope: Guardian.new(user)) }

      it "returns nil" do
        expect(serializer.passport_score).to eq(nil)
      end
    end
  end

  describe "admin_detailed_user_serializer#min_score_to_post" do
    context "when user passport score to post requirement does not exist" do
      let(:passport_score_exists) { Fabricate(:user, passport_score: 10) }
      let(:serializer) { AdminDetailedUserSerializer.new(passport_score_exists, scope: Guardian.new(passport_score_exists)) }

      it "returns nil" do
        expect(serializer.min_score_to_post).to eq(0)
      end
    end

    context "when user passport score to post requirement exists" do
      let(:passport_score_exists) { Fabricate(:user, passport_score: 10) }
      let(:serializer) { AdminDetailedUserSerializer.new(passport_score_exists, scope: Guardian.new(passport_score_exists)) }

      before do
        UserPassportScore.create!(user_id: passport_score_exists.id, user_action_type: UserAction.types[:reply], required_score: 20.0)
      end

      it "returns nil" do
        expect(serializer.min_score_to_post).to eq(20.0)
      end
    end
  end

  describe "admin_detailed_user_serializer#min_score_to_create_topic" do
    context "when user passport score to post requirement does not exist" do
      let(:passport_score_exists) { Fabricate(:user, passport_score: 10) }
      let(:serializer) { AdminDetailedUserSerializer.new(passport_score_exists, scope: Guardian.new(passport_score_exists)) }

      it "returns nil" do
        expect(serializer.min_score_to_create_topic).to eq(0)
      end
    end

    context "when user passport score to post requirement exists" do
      let(:passport_score_exists) { Fabricate(:user, passport_score: 10) }
      let(:serializer) { AdminDetailedUserSerializer.new(passport_score_exists, scope: Guardian.new(passport_score_exists)) }

      before do
        UserPassportScore.create!(user_id: passport_score_exists.id, user_action_type: UserAction.types[:new_topic], required_score: 10.0)
      end

      it "returns nil" do
        expect(serializer.min_score_to_create_topic).to eq(10.0)
      end
    end
  end

  describe "category_serializer#min_score_to_post" do
    context "when category passport score to post requirement does not exist" do
      let(:category) { Fabricate(:category) }
      let(:serializer) { CategorySerializer.new(category, scope: Guardian.new) }

      it "returns nil" do
        expect(serializer.min_score_to_post).to eq(0)
      end
    end

    context "when category passport score to post requirement exists" do
      let(:category) { Fabricate(:category) }
      let(:serializer) { CategorySerializer.new(category, scope: Guardian.new) }

      before do
        CategoryPassportScore.create!(category_id: category.id, user_action_type: UserAction.types[:reply], required_score: 20.0)
      end

      it "returns nil" do
        expect(serializer.min_score_to_post).to eq(20.0)
      end
    end
  end

  describe "category_serializer#min_score_to_create_topic" do
    context "when category passport score to post requirement does not exist" do
      let(:category_level_requirement) { Fabricate(:category_level_requirement) }
      let(:serializer) { CategorySerializer.new(category_level_requirement, scope: Guardian.new) }

      it "returns nil" do
        expect(serializer.min_score_to_create_topic).to eq(0)
      end
    end

    context "when category passport score to post requirement exists" do
      let(:category_level_requirement) { Fabricate(:category_level_requirement) }
      let(:serializer) { CategorySerializer.new(category_level_requirement, scope: Guardian.new) }

      before do
        CategoryPassportScore.create!(category_id: category_level_requirement.id, user_action_type: UserAction.types[:new_topic], required_score: 10.0)
      end

      it "returns nil" do
        expect(serializer.min_score_to_create_topic).to eq(10.0)
      end
    end
  end
end
