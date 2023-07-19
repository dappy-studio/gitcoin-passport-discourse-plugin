# frozen_string_literal: true

require "rails_helper"

RSpec.describe DiscourseGitcoinPassport::PassportController do
  routes { ::DiscourseGitcoinPassport::Engine.routes }

  before do
    SiteSetting.gitcoin_passport_enabled = true
    SiteSetting.gitcoin_passport_scorer_id = 0
  end

  describe 'GET #score' do
    let(:ethaddress) { '0x123456789abcdef' }

    before do
      stub_fetch_score_request({
        address: ethaddress,
        scorer_id: SiteSetting.gitcoin_passport_scorer_id
      }.to_json, {
        score: 42
      }.to_json)

    end

    it 'returns the user score' do
      session['authentication'] = { 'extra_data' => { 'uid' => ethaddress } }

      get :score, format: :json
      expect(response.status).to eq(200)
      expect(JSON.parse(response.body)).to eq({ 'score' => 42 })
    end

    it 'raises an error if the wallet is not connected' do
      session['authentication'] = nil
      get :score, format: :json
      expect(response.status).to eq(403)
    end
  end

  describe 'POST saveUserScore' do
    context "when Gitcoin Passport is enabled and scorer ID is set" do
      let(:user) { Fabricate(:user, admin: true) }

      before do
        SiteSetting.gitcoin_passport_enabled = true
        provider = log_in_user(user)
      end

      it 'saves the user passport score' do
        user_id = user.id
        score = 10.0
        action_id = 1

        post :saveUserScore, format: :json, params: { user_id: user_id, score: score, action_id: action_id }

        expect(response.status).to eq(200)
        expect(UserPassportScore.where(user_id: user_id, user_action_type: action_id).exists?).to be_truthy

        last_passport_score = UserPassportScore.last.attributes
        last_passport_score_with_UTC_dates = last_passport_score.transform_values do |value|
          conver_timestamp_to_iso_8601(value)
        end
        response_body = JSON.parse(response.body)
        response_body_scores_with_UTC_dates = response_body['user_passport_score'].transform_values do |value|
          remove_milliseconds_from_datetime(value)
        end

        expect(response_body_scores_with_UTC_dates).to eq(last_passport_score_with_UTC_dates)
      end

      it 'updates the existing user passport score' do
        user_passport_score = Fabricate(:user_passport_score, user: user)
        user_id = user.id
        score = 20.0
        action_id = 1

        post :saveUserScore, format: :json, params: { user_id: user_id, score: score, action_id: action_id }

        expect(response.status).to eq(200)
        expect(UserPassportScore.find(user_passport_score.id).required_score).to eq(score)

        last_passport_score = UserPassportScore.last.attributes
        last_passport_score_with_UTC_dates = last_passport_score.transform_values do |value|
          conver_timestamp_to_iso_8601(value)
        end
        response_body = JSON.parse(response.body)
        response_body_scores_with_UTC_dates = response_body['user_passport_score'].transform_values do |value|
          remove_milliseconds_from_datetime(value)
        end

        expect(response_body_scores_with_UTC_dates).to eq(last_passport_score_with_UTC_dates)
      end
    end

    context 'user is not logged in' do
      let(:user) { Fabricate(:user, admin: true) }

      it 'returns an error if the user is not logged in' do
        user_id = user.id
        score = 10.0
        action_id = 1
        post :saveUserScore, format: :json,  params: { user_id: user_id, score: score, action_id: action_id }

        expect(JSON.parse(response.body)).to eq({ 'status' => 403, 'error' => 'You must be logged in to access this resource' })
      end
    end

    context 'user is not staff' do
      let(:user) { Fabricate(:user, admin: false) }

      before do
        SiteSetting.gitcoin_passport_enabled = true
        provider = log_in_user(user)
      end

      it 'returns an error if the user is not an admin' do
        post :saveUserScore, format: :json, params: { user_id: user.id, score: 10.0, action_id: 1 }

        expect(JSON.parse(response.body)).to eq({ 'status' => 403, 'error' => 'You must be an admin to access this resource' })
      end
    end
  end

  describe 'POST saveCategoryScore' do
    context "when Gitcoin Passport is enabled and scorer ID is set" do
      let(:user) { Fabricate(:user, admin: true) }
      let(:category) { Fabricate(:category) }

      before do
        SiteSetting.gitcoin_passport_enabled = true
        provider = log_in_user(user)
      end

      it 'saves the category passport score' do
        category_id = category.id
        score = 10.0
        action_id = 1

        post :saveCategoryScore, format: :json, params: { category_id: category_id, score: score, action_id: action_id }

        expect(response.status).to eq(200)
        expect(CategoryPassportScore.where(category_id: category_id, user_action_type: action_id).exists?).to be_truthy

        last_passport_score = CategoryPassportScore.last.attributes
        last_passport_score_with_UTC_dates = last_passport_score.transform_values do |value|
          conver_timestamp_to_iso_8601(value)
        end
        response_body = JSON.parse(response.body)
        response_body_scores_with_UTC_dates = response_body['category_passport_score'].transform_values do |value|
          remove_milliseconds_from_datetime(value)
        end

        expect(response_body_scores_with_UTC_dates).to eq(last_passport_score_with_UTC_dates)
      end

      it 'updates the existing category passport score' do
        category_passport_score = Fabricate(:category_passport_score, category: category)
        category_id = category.id
        score = 20.0
        action_id = 1

        post :saveCategoryScore, format: :json, params: { category_id: category_id, score: score, action_id: action_id }

        expect(response.status).to eq(200)
        expect(CategoryPassportScore.find(category_passport_score.id).required_score).to eq(score)

        last_passport_score = CategoryPassportScore.last.attributes
        last_passport_score_with_UTC_dates = last_passport_score.transform_values do |value|
          conver_timestamp_to_iso_8601(value)
        end
        response_body = JSON.parse(response.body)
        response_body_scores_with_UTC_dates = response_body['category_passport_score'].transform_values do |value|
          remove_milliseconds_from_datetime(value)
        end

        expect(response_body_scores_with_UTC_dates).to eq(last_passport_score_with_UTC_dates)
      end
    end

    context 'user is not logged in' do
      let(:user) { Fabricate(:user, admin: true) }
      let(:category) { Fabricate(:category) }

      it 'returns an error if the user is not logged in' do
        category_id = category.id
        score = 10.0
        action_id = 1
        post :saveCategoryScore, format: :json,  params: { category_id: category_id, score: score, action_id: action_id }

        expect(JSON.parse(response.body)).to eq({ 'status' => 403, 'error' => 'You must be logged in to access this resource' })
      end
    end

    context 'user doesnt have permission' do
      let(:user) { Fabricate(:user, admin: false) }
      let(:category) { Fabricate(:category) }

      before do
        SiteSetting.gitcoin_passport_enabled = true
        provider = log_in_user(user)
      end

      it 'returns an error if the user is not an admin' do
        post :saveCategoryScore, format: :json, params: { category_id: category.id, score: 10.0, action_id: 1 }

        expect(JSON.parse(response.body)).to eq({ 'status' => 403, 'error' => 'You must be an admin to access this resource' })
      end
    end
  end
end
