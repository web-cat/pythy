FactoryGirl.define do
  factory :sys_config, class: SystemConfiguration do
    storage_path  Rails.root.join('spec', 'test_storage_path').to_s
    work_path     Rails.root.join('spec', 'test_work_path').to_s
  end
end
