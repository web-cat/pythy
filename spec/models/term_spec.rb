require 'spec_helper'

describe Term do
  let(:spring_term)  { FactoryGirl.build(:spring_term) }
  let(:summer1_term) { FactoryGirl.build(:summer1_term) }
  let(:summer2_term) { FactoryGirl.build(:summer2_term) }
  let(:fall_term)    { FactoryGirl.build(:fall_term) }
  let(:winter_term)  { FactoryGirl.build(:winter_term) }

  subject { summer1_term }

  # Attribute testing
  it { should respond_to(:ends_on) }
  it { should respond_to(:starts_on) }
  it { should respond_to(:season) }
  it { should respond_to(:year) }

  # Association testing
  it { should have_many(:assignments) }

  # Validation testing
  it { should be_valid }

  describe "when season is not present" do
    before { summer1_term.season = '' }

    it { should be_invalid }
  end 

  describe "when season is invalid" do
    before { summer1_term.season = 120 }

    it { should be_invalid }
  end

  describe "when end date is not present" do
    before { summer1_term.ends_on = '' }

    it { should be_invalid }
  end 

  describe "when start date is not present" do
    before { summer1_term.starts_on = '' }

    it { should be_invalid }
  end 

  describe "when start date is greater than or equal to end date" do
    before { summer1_term.ends_on = summer1_term.starts_on - 1 }

    it { should be_invalid }
  end

  describe "when year is invalid" do
    before { summer1_term.year = ''}

    it { should be_invalid }
  end 

  describe ".latest_first should return the terms in descending order" do
    before do
      spring_term.save
      summer2_term.save
      fall_term.save
      winter_term.save
    end

    let(:terms) { Term.latest_first }

    subject { terms }

    its(:first)  { should eq(winter_term) }
    its(:second) { should eq(fall_term) }
    its(:third)  { should eq(summer2_term) }
    its(:fourth) { should eq(spring_term) }

    after do
      spring_term.destroy
      summer2_term.destroy
      fall_term.destroy
      winter_term.destroy
    end
  end

  describe "#season_name" do
    specify { expect(spring_term.season_name).to eq("Spring") }
    specify { expect(summer1_term.season_name).to eq("Summer I") }
    specify { expect(summer2_term.season_name).to eq("Summer II") }
    specify { expect(fall_term.season_name).to eq("Fall") }
    specify { expect(winter_term.season_name).to eq("Winter") }
  end

  describe "#contains?" do
    specify { expect(spring_term.contains?(Date.new(2012, 3, 23))).to be(true) } 
    specify { expect(spring_term.contains?(Date.new(2012, 6, 23))).to be(false) } 
  end

  describe "#contains_now?" do
    before { DateTime.stub(:now) { Date.new(2012, 3, 23) } }

    specify { expect(spring_term.contains_now?).to be(true) } 
    specify { expect(summer1_term.contains_now?).to be(false) } 
  end

  describe "#display_name" do
    specify { expect(spring_term.display_name).to eq("Spring 2012")  }
  end

  describe "#url_part" do
    specify { expect(summer2_term.url_part).to eq("summerii-2012")  }
  end

  describe ".from_path_component" do
    before { summer2_term.save }
    let(:path) { summer2_term.url_part }

    specify { expect(Term.from_path_component(path).first).to eq(summer2_term)}
    specify { expect(Term.from_path_component('wrong path').first).to be_nil}

    after { summer2_term.destroy }
  end

  describe "when updated, it should update the file paths" do
    pending "complete with user spec"
  end

end
