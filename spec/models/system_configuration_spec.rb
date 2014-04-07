require 'spec_helper'

describe SystemConfiguration do
  let(:sys_config) { FactoryGirl.build(:sys_config) }
  subject { sys_config }

  it { should be_valid }
  it { should respond_to(:storage_path) }
  it { should respond_to(:work_path) }

  describe "when storage_path is empty" do
    before { sys_config.storage_path = ''}
    it { should_not be_valid }
  end

  describe "when work_path is empty" do
    before { sys_config.work_path = ''}
    it { should_not be_valid }
  end

  describe "when the rails server doesn't have permission
  to write to the storage_path" do
    before { sys_config.storage_path = '/' }
    it { should_not be_valid }
  end

  describe "when the rails server doesn't have permission
  to write to the work_path" do
    before { sys_config.work_path = '/' }
    it { should_not be_valid }
  end

end
