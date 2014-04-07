require 'spec_helper'

describe Environment do
  let(:environment) { FactoryGirl.build(:environment) }

  subject { environment }

  # Attribute testing
  it { should respond_to(:name) }
  it { should respond_to(:preamble) }

  # Association testing
  it { should have_many(:courses).with_foreign_key('default_environment_id') }
  it { should have_many(:repositories) }

  # Validation testing
  it { should be_valid }

  describe "when name is not present" do
      before { environment.name = '' }

      it { should be_invalid }
  end

end
