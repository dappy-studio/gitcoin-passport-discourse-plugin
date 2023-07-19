# frozen_string_literal: true

require "rails_helper"

RSpec.describe Admin::UsersController do
  let(:admin) { Fabricate(:admin) }

  before { sign_in(admin) }

  describe "#destroy" do
    let(:delete_category) { Fabricate(:category) }

    context "when user has passport score" do
      let!(:category_passport_score) { Fabricate(:category_passport_score, category: delete_category) }

      it "deletes the user" do
        CategoryPassportScore.create!(category_id: delete_category.id, user_action_type: UserAction.types[:reply], required_score: 10)

        delete "/categories/#{delete_category.id}.json"
        expect(response.status).to eq(200)
        expect(Category.exists?(id: delete_category.id)).to eq(false)
        expect(CategoryPassportScore.exists?(category_id: delete_category.id)).to eq(false)
      end
    end
  end
end
