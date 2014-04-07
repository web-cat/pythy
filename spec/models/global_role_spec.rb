require 'spec_helper'

describe GlobalRole do
  let(:global_role) { FactoryGirl.build(:global_role) }

  subject { global_role }

  it { should respond_to(:name) }
  it { should respond_to(:builtin) }

  it "should be seeded with the roles 'administrator',
      'regular_user' and 'instructor'" do
    expect(GlobalRole.count).to eq(3)
    expect(GlobalRole.administrator).not_to be_nil
    expect(GlobalRole.regular_user).not_to be_nil
    expect(GlobalRole.instructor).not_to be_nil
  end  

  describe "builtin roles" do
    let(:builtin_role) { GlobalRole.administrator }

    subject { builtin_role }

    it { should respond_to(:can_edit_system_configuration) }
    it { should respond_to(:can_manage_all_courses) }
    it { should respond_to(:can_create_courses) }

    describe "'s properties should not be update-able" do
      before do
        builtin_role.update(can_edit_system_configuration: false)
        builtin_role.update(can_manage_all_courses: false)
        builtin_role.update(can_create_courses: false)
        builtin_role.reload
      end

      its(:can_edit_system_configuration) { should eq(true) }
      its(:can_manage_all_courses) { should eq(true) }
      its(:can_create_courses) { should eq(true) }

    end
  end

  describe "when name is not present" do
    before { global_role.name = "" }
    it { should be_invalid }
  end

  describe "when name is not unique" do
    let!(:new_user) { FactoryGirl.create(:global_role) }

    it do
      should be_invalid
    end

    after { new_user.destroy }
  end

end
