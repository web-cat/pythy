require 'spec_helper'

describe ActivityLog do
  let(:user) { FactoryGirl.create(:user) }
  let(:activity_log1) { FactoryGirl.build(:activity_log1, user: user) }
  let(:activity_log2) { FactoryGirl.build(:activity_log2, user: user) }

  subject { activity_log1 }

  # Association testing
  it { should belong_to(:user) }

  # Validation testing
  it { should be_valid }

  describe "when user is not present" do
    before { activity_log1.user = nil }

    it { should be_invalid }
  end

  describe "when action is not present" do
    before { activity_log1.action = '' }

    it { should be_invalid }
  end

  describe "after saving" do
    before do
      activity_log1.save
      # Sleeping in tests is considered bad practice
      # but downloading a gem for this one case is overkill
      sleep(1)
      activity_log2.save
      activity_log1.reload
    end

    # Tests serialization of info
    its(:info) do
      should be_a(Hash)
      should have_key(:location)
      should have_key(:type)
    end

    it "should arrange activity logs in the descending order" do
      expect(ActivityLog.all).to eq([activity_log2, activity_log1])
    end

    describe ".all_actions" do
      specify { expect(ActivityLog.all_actions('Test')).to eq(['Test Log1', 'Test Log2']) }
    end

    after do
      activity_log1.destroy
      activity_log2.destroy
    end
  end

  after { user.destroy }

end
