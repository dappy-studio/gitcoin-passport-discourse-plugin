Fabricator(:user_passport_score, class_name:"UserPassportScore") do
  user_id "1"
  user_action_type "1"
  required_score "10.0"
end

Fabricator(:user_associated_account_siwe, class_name:"UserAssociatedAccount") do
  user_id "1"
  provider_name "siwe"
end
