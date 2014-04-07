FactoryGirl.define do
  factory :user do
    first_name            "Example"
    last_name             "User"
    email                 "example_user@example.com"
    password              "foobar"
    password_confirmation "foobar"
  end

  factory :user_one, class: User do
    first_name             "Test"
    last_name              "User"
    email                  "user_1@example.com"
    password               "foobar"
    password_confirmation  "foobar"
  end

  factory :user_two, class: User do
    first_name             "Test"
    last_name              "User"
    email                  "user_2@example.com"
    password               "foobar"
    password_confirmation  "foobar"
  end

  factory :user_three, class: User do
    first_name              "Test"
    last_name               "User"
    email                   "user_3@example.com"
    password                "foobar"
    password_confirmation   "foobar"
  end
end
