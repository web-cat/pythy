FactoryGirl.define do
  factory :summer1_term, class: Term do
    starts_on   Date.new(2012, 5, 28)
    ends_on     Date.new(2012, 7, 1)
    season      Term::SEASONS['Summer I']
    year        2012
  end
  factory :spring_term, class: Term do
    starts_on   Date.new(2012, 1, 28)
    ends_on     Date.new(2012, 5, 10)
    season      Term::SEASONS['Spring']
    year        2012
  end
  factory :summer2_term, class: Term do
    starts_on   Date.new(2012, 7, 1)
    ends_on     Date.new(2012, 8, 10)
    season      Term::SEASONS['Summer II']
    year        2012
  end
  factory :fall_term, class: Term do
    starts_on   Date.new(2012, 8, 23)
    ends_on     Date.new(2012, 12, 10)
    season      Term::SEASONS['Fall']
    year        2012
  end
  factory :winter_term, class: Term do
    starts_on   Date.new(2012, 12, 15)
    ends_on     Date.new(2013, 1, 20)
    season      Term::SEASONS['Winter']
    year        2012
  end
end
