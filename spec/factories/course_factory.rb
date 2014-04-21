FactoryGirl.define do
  factory :course, class: Course do
    name "Introduction to Media Computation"
    number "CS 1124"
    default_environment_id Environment.first.id
    organization
  end
end
