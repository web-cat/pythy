require 'spec_helper'

describe Course do
  let(:course) { FactoryGirl.build(:course) }

  subject { course }

  # Attribute testing
  it { should respond_to(:name) }
  it { should respond_to(:number) }
  it { should respond_to(:url_part) }
  it { should respond_to(:organization_id) }
  it { should respond_to(:default_environment_id) }

  # Association testing
  it { should belong_to(:organization) }
  it { should belong_to(:default_environment).class_name('Environment') }
  it { should have_many(:course_offerings) }
  it { should have_many(:assignments) }

  # Validation testing
  it { should be_valid }

  describe "when number is not present" do
    before { course.number = '' }

    it { should be_invalid }
  end

  describe "when number is not present" do
    before { course.number = '' }

    it { should be_invalid }
  end

  describe "when default_environment is not present" do
    before { course.default_environment = nil }

    it { should be_invalid }
  end

  describe "when organization is not present" do
    before { course.organization = nil }

    it { should be_invalid }
  end

  describe "when saved" do
    before { course.save }

    its(:url_part) { should eq("cs-1124") }

    after { course.destroy }
  end

  # Also takes care of url_part uniqueness as it is constructed from the course number
  describe "when course number is the same" do
    let(:new_course) { course.clone }
    before { new_course.save }

    it { should be_invalid }

    after  { new_course.destroy }
  end

  describe "when updated" do
    it "should update the file paths" do
      pending "will complete with user"
    end
  end

  describe ".from_path_component" do
    before { course.save }

    specify do
      expect(Course
             .from_path_component(course.url_part)
             .first).to eq(course)
    end

    after { course.destroy }
  end

  describe "#offering_with_short_label" do
    it "should get the course_offering for the given term" do
      pending "complete after tests for course_offering"
    end 
  end

  describe "#offerings_for_user" do
    it "should get the courses offered to the given user" do
    end
  end

end
