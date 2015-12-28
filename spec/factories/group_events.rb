FactoryGirl.define do
  factory :group_event do
    name 'Test Group Event'
    description 'Lorem Ipsum dolores sit amet'
    start_date { Date.today }
    end_date { Date.today.next_day(3) }
    location 'At test location'
  end
end
