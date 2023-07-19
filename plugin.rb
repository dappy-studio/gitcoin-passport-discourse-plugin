# frozen_string_literal: true

# name: discourse-gitcoin-passport
# about: A discourse plugin to enable users to manage forum access using Gitcoin Passport
# version: 0.0.1
# authors: Spect
# url: https://passport.gitcoin.co/
# required_version: 2.7.0

enabled_site_setting :gitcoin_passport_enabled

register_asset "stylesheets/create-account-feedback-message.scss"
register_asset "stylesheets/passport-score-value.scss"


require_relative "app/validators/ethaddress_validator.rb"
require_relative "app/validators/date_validator.rb"


after_initialize do
  module ::DiscourseGitcoinPassport
    PLUGIN_NAME = "discourse-gitcoin-passport"

    class Engine < ::Rails::Engine
      engine_name PLUGIN_NAME
      isolate_namespace DiscourseGitcoinPassport
    end

    class Error < StandardError
    end
  end


  require_relative "app/controllers/passport_controller.rb"
  require_relative "lib/gitcoin_passport_module/passport.rb"
  require_relative "lib/gitcoin_passport_module/access_without_passport.rb"
  require_relative "app/models/user_passport_score.rb"
  require_relative "app/models/category_passport_score.rb"


  DiscourseGitcoinPassport::Engine.routes.draw do
    get "/score" => "passport#score"
    put "/saveUserScore" => "passport#saveUserScore"
    put "/saveCategoryScore" => "passport#saveCategoryScore"
    put "/refreshPassportScore" => "passport#refreshPassportScore"
  end


  Discourse::Application.routes.append { mount ::DiscourseGitcoinPassport::Engine, at: "/passport" }

  reloadable_patch do |plugin|
    User.class_eval { has_many :user_passport_scores, dependent: :destroy }
    Category.class_eval { has_many :category_passport_scores, dependent: :destroy }


    UsersController.class_eval do
      alias_method :existing_create, :create
      def create
        if SiteSetting.gitcoin_passport_enabled && SiteSetting.gitcoin_passport_scorer_id
          sesh_hash = session.to_hash
          ethaddress = sesh_hash['authentication']['extra_data']['uid'] if sesh_hash['authentication'] && sesh_hash['authentication']['extra_data']
          if (!ethaddress)
            return fail_with("gitcoin_passport.create_account_wallet_not_connected")
          end

          score = DiscourseGitcoinPassport::Passport.score(ethaddress, SiteSetting.gitcoin_passport_scorer_id)
          required_score_to_create_account = SiteSetting.gitcoin_passport_forum_level_score_to_create_account.to_f || 0

          if score.to_i < required_score_to_create_account
            message = I18n.t("gitcoin_passport.create_account_minimum_score_not_satisfied", score: score, required_score: required_score_to_create_account)
            render json: { success: false, message: message }
            return
          end
        end
        existing_create
      end
    end

    SiweAuthenticator.class_eval do
      def after_authenticate(auth_token, existing_account: nil)
        association = UserAssociatedAccount.where(provider_name: auth_token[:provider], provider_uid: auth_token[:uid]).first
        # If the user is already associated with an account, refresh the score and save it in the user table, this is mainly done
        # for performance reasons so that we don't have to query the passport api every time we need to check the score
        if association and association.user_id
            user = User.where(id: association.user_id).first
            score = DiscourseGitcoinPassport::Passport.refresh_passport_score(user)
            if !score
              score = 0
            end
            user.update(passport_score: score, passport_score_last_update: Time.now)
        end

        super
      end

      def after_create_account(user, auth)
        if SiteSetting.gitcoin_passport_enabled
          score = DiscourseGitcoinPassport::Passport.score(auth[:extra_data][:uid], SiteSetting.gitcoin_passport_scorer_id)
          if !score
            score = 0
          end
          user.update(passport_score: score, passport_score_last_update: Time.now)
        end
        super
      end
    end


    TopicGuardian.class_eval do
      alias_method :existing_can_create_post_on_topic?, :can_create_post_on_topic?
      alias_method :existing_can_create_topic_on_category?, :can_create_topic_on_category?

      def can_create_post_on_topic?(topic)
        if DiscourseGitcoinPassport::AccessWithoutPassport.expired?
          category = Category.where(id: topic.category_id).first
          if !DiscourseGitcoinPassport::Passport.has_minimimum_required_score?(@user, category, UserAction.types[:reply])
            return false
          end
        end
        existing_can_create_post_on_topic?(topic)
      end

      def can_create_topic_on_category?(category)

        if DiscourseGitcoinPassport::AccessWithoutPassport.expired?
          if !DiscourseGitcoinPassport::Passport.has_minimimum_required_score?(@user, category, UserAction.types[:new_topic])
            return false
          end
        end
        existing_can_create_topic_on_category?(category)
      end
    end
  end

  add_to_serializer(
    :current_user,
    :ethaddress,
  ) do
    siwe_account = object.associated_accounts.find { |account| account[:name] == "siwe" }
    siwe_account[:description] if siwe_account
  end

  add_to_serializer(
    :current_user,
    :passport_score,
  ) do
    object.passport_score
  end

  add_to_serializer(
    :admin_detailed_user,
    :min_score_to_post,
  ) do
    UserPassportScore
      .where(user_id: object.id, user_action_type: UserAction.types[:reply]).exists? ? UserPassportScore.where(user_id: object.id, user_action_type: UserAction.types[:reply]).first.required_score : 0
  end

  add_to_serializer(
    :admin_detailed_user,
    :min_score_to_create_topic,
  ) do
    UserPassportScore
      .where(user_id: object.id, user_action_type: UserAction.types[:new_topic]).exists? ? UserPassportScore.where(user_id: object.id, user_action_type: UserAction.types[:new_topic]).first.required_score : 0
  end

  add_to_serializer(
    :category,
    :min_score_to_post,
  ) do
    CategoryPassportScore
      .where(category_id: object.id, user_action_type: UserAction.types[:reply]).exists? ? CategoryPassportScore.where(category_id: object.id, user_action_type: UserAction.types[:reply]).first.required_score : 0
  end

  add_to_serializer(
    :category,
    :min_score_to_create_topic,
  ) do
    CategoryPassportScore
      .where(category_id: object.id, user_action_type: UserAction.types[:new_topic]).exists? ? CategoryPassportScore.where(category_id: object.id, user_action_type: UserAction.types[:new_topic]).first.required_score : 0
  end
end
