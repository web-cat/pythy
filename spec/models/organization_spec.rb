require 'spec_helper'

describe Organization do
  let(:organization) { FactoryGirl.build(:organization) }

  subject { organization }

  # Attribute testing
  it { should respond_to(:display_name) }
  it { should respond_to(:domain) }
  it { should respond_to(:abbreviation) }
  it { should respond_to(:url_part) }

  # Association testing
  it { should have_many(:courses) }

  # Validation testing
  it { should be_valid }

  describe "when abbreviation is invalid" do
    before { organization.abbreviation='v))*t' }

    it { should be_invalid }
  end

  describe "when abbreviation is not unique" do
    let(:new_organization) { organization.clone }

    before do
      new_organization.save
      organization.abbreviation.upcase
    end

    it { should be_invalid }

    after { new_organization.destroy }
  end

  describe "after saving" do
    before { organization.save }

    its(:url_part) { should eq("vt") }

    after { organization.destroy }
  end

  describe "when display_name is blank" do
    before { organization.display_name = '' }

    it { should be_invalid }
  end

  describe ".from_path_component" do
    before { organization.save }

    specify do
      expect(Organization
             .from_path_component(organization.url_part)
             .first).to eq(organization)
    end

    after { organization.destroy }
  end

  describe ".matches_user" do
    let(:vt_user) { FactoryGirl.build(:vt_user) }
    let(:non_vt_user) { FactoryGirl.build(:user) }

    specify { expect(organization.matches_user?(vt_user)).not_to be_nil }
    specify { expect(organization.matches_user?(non_vt_user)).to be_nil }
  end

  describe "on update" do
    it "should update the file paths" do
      pending "complete with user"
    end
  end

end
