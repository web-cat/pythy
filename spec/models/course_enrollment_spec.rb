require 'spec_helper'

describe CourseEnrollment do

  let(:course_enrollment) { FactoryGirl.build(:course_enrollment) }

  subject { course_enrollment }

  # Association testing
  it { should belong_to(:user) }
  it { should belong_to(:course_offering) }
  it { should belong_to(:course_role) }

  # Validation testing
  it { should be_valid }

  describe "when user is not present" do
    before { course_enrollment.user = nil }
    it { should be_invalid }
  end

  describe "when course_offering is not present" do
    before { course_enrollment.course_offering = nil }
    it { should be_invalid }
  end

  describe "when course_role is not present" do
    before { course_enrollment.course_role = nil }
    it { should be_invalid }
  end

end
