Fabricator(:unique_humanity_badge_group, class_name: "BadgeGrouping") do
  name "Unique Humanity"
  position 1
end

Fabricator(:unique_humanity_silver_badge, class_name: "Badge" ) do
  name "Unique Humanity Silver"
end

Fabricator(:unique_humanity_gold_badge, class_name: "Badge") do
  name "Unique Humanity Gold"
end

Fabricator(:unique_humanity_bronze_badge, class_name: "Badge") do
  name "Unique Humanity Bronze"
end
