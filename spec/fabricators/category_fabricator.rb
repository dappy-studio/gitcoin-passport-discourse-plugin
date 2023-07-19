Fabricator(:category_level_requirement, class_name: "Category") do
  name { sequence(:category_name) { |i| "category_#{i}" } }
  user { Fabricate(:user) }
end


Fabricator(:category_passport_score, class_name:"CategoryPassportScore") do
  category_id "1"
  user_action_type "1"
  required_score "10.0"
end
