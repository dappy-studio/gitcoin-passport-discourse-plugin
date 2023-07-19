# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UsersController do
  let(:admin) { Fabricate(:admin) }

  before { sign_in(admin) }

  describe "#destroy" do
    let(:delete_me) { Fabricate(:user) }

    context "when user has passport score" do
      let!(:user_passport_score) { Fabricate(:user_passport_score, user: delete_me) }

      it "deletes the user" do
        UserPassportScore.create!(user_id: delete_me.id, user_action_type: UserAction.types[:reply], required_score: 10)

        delete "/admin/users/#{delete_me.id}.json"
        expect(response.status).to eq(200)
        expect(User.exists?(id: delete_me.id)).to eq(false)
        expect(UserPassportScore.exists?(user_id: delete_me.id)).to eq(false)
      end
    end
  end
end

