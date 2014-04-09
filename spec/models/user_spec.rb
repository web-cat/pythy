require 'spec_helper'

describe User do
  let(:user) { FactoryGirl.build(:user) }
  # Temp users
  let(:user_one) { FactoryGirl.build(:user_one) }
  let(:user_two) { FactoryGirl.build(:user_two) }
  let(:user_three) { FactoryGirl.build(:user_three) }
  # Overriding the lazy execution of 'let' to
  # create a System Configuration entry in the db immediately
  let!(:sys_config) { FactoryGirl.create(:sys_config) }

  after do
    user.destroy
    user_one.destroy
    user_two.destroy
    user_three.destroy
    sys_config.destroy
  end

  subject { user }

  # Attribute testing
  it { should respond_to(:first_name) }
  it { should respond_to(:last_name) }
  it { should respond_to(:email) }
  it { should respond_to(:password) }
  it { should respond_to(:password_confirmation) }
  it { should respond_to(:storage_path) }
  its(:storage_path) do
    should eq("#{sys_config.storage_path}/users/#{user.email}")
  end

  # Related to cancan
  it { should respond_to(:can?) }
  it { should respond_to(:cannot?) }
  it { should respond_to(:ability) }
  its(:ability) { should be_nil }

  # Association testing
  it { should belong_to(:global_role) }
  it { should have_many(:authentications) }
  it { should have_many(:activity_logs) }
  it { should have_many(:course_enrollments) }
  it { should have_many(:course_offerings).through(:course_enrollments) }
  it { should have_many(:assignment_offerings).through(:course_offerings) }
  it { should have_many(:media_items) }
  it { should have_one(:scratchpad_repository) }

  # Validation testing
  it { should be_valid }

  describe "when first name is not present" do
      before { user.first_name = '' }

      it { should be_invalid }
  end

  describe "when last name is not present" do
      before { user.last_name = '' }

      it { should be_invalid }
  end

  # All the other validations are handled by devise

  describe "after saving" do
    before { user.save }

    its(:resource_key) { should_not be_nil }
    # Until it is saved, it will not be assigned a
    # global role and hence an ability can not be
    # created
    its(:ability) { should be_an(Ability) }

    describe "the first user should be an administrator" do
      its(:global_role) { should eq(GlobalRole.administrator) }
    end

    describe "all the other users should be regular users" do
      before { user_two.save } 
      
      specify { expect(user_two.global_role).to eq(GlobalRole.regular_user) }

      after { user_two.destroy }
    end

    after { user.destroy }
  end

  # This test is dependent on assignment_repository,
  # scratchpad_repository and system_configuration
  describe "when updated" do
    before do
      user.save
      user.email = "#{user.email}m"
      user.save
    end
    it "should update the file paths" do
      pending "complete after going through the assignment_repository
      scratchpad_repository and system_configuration models"
    end
  end 

  describe ".search" do
    before { user.save }
    it "should should match user's first name" do
      expect(User.search("ex").count).to be(1)
    end
    it "should should match user's last name" do
      expect(User.search("user").count).to be(1)
    end
    it "should should match user's email" do
      expect(User.search("@").count).to be(1)
    end
    it "should should return a chainable result" do
      expect(User.search("ex")).to be_an(ActiveRecord::Relation)
    end
    after { user.destroy }
  end

  describe ".alphabetical" do
    after do
      user_three.destroy
      user_two.destroy
      user_one.destroy
    end

    it "should sort by last name first" do
      user_one.last_name   = "A"
      user_two.last_name   = "B"
      user_three.last_name = "C"

      user_three.save
      user_two.save
      user_one.save

      expect(User.alphabetical.first).to eq(user_one)
    end

    it "should sort by first name second" do
      user_one.first_name   = "A"
      user_two.first_name   = "B"
      user_three.first_name = "C"

      user_three.save
      user_two.save
      user_one.save

      expect(User.alphabetical.first).to eq(user_one)
    end

    it "should sort by email third" do
      user_one.email   = "a_#{user_one.email}"
      user_two.email   = "b_#{user_two.email}"
      user_three.email = "c_#{user_three.email}"

      user_three.save
      user_two.save
      user_one.save

      expect(User.alphabetical.first).to eq(user_one)
    end

    it "should should return a chainable result" do
      expect(User.alphabetical).to be_an(ActiveRecord::Relation)
    end

  end

  describe ".all_emails" do

    before do
      user_three.save
      user_two.save
      user_one.save
    end

    after do
      user_three.destroy
      user_two.destroy
      user_one.destroy
    end

    it "should list all emails in ascending order" do
      expect(User.all_emails).to eq([user_one.email, user_two.email,
                                    user_three.email])
    end
  end

  describe ".course" do
    it "should get a dictionary of term ids and courses" do
      pending "complete after going through course model"
    end
  end

  describe ".managing_course_offerings" do
    it "should get the only those courses that the user can manage" do
      pending "complete after going through course model"
    end
  end

  describe ".display_name" do
    specify do
      expect(user.display_name).to eq("#{user.first_name} #{user.last_name}")
    end

    describe "when first name isn't present" do
      before { user.first_name = '' }
      specify { expect(user.display_name).to eq("#{user.email}") }
    end

    describe "when last name isn't present" do
      before { user.last_name = '' }
      specify { expect(user.display_name).to eq("#{user.email}") }
    end

  end

  describe ".email_without_domain" do
    specify do
      expect(user.email_without_domain).to eq(user.email.split('@').first)
    end
  end

end
