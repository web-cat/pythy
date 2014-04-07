FactoryGirl.define do
  factory :activity_log1, class: ActivityLog do
    user
    action  "Test Log1"
    info    location: "Factory", type: "Test" 
  end
  factory :activity_log2, class: ActivityLog do
    user
    action  "Test Log2"
    info    location: "Factory", type: "Test" 
  end
end
