require 'spec_helper'

describe CourseRole do
  let(:course_role) { FactoryGirl.build(:course_role) }

  subject { course_role }

  it { should respond_to(:name) }
  it { should respond_to(:builtin) }
  its(:can_manage_course ) { should eq(false) }
  its(:can_manage_assignments ) { should eq(false) }
  its(:can_grade_submissions ) { should eq(false) }
  its(:can_view_other_submissions ) { should eq(false) }

  it "should be seeded with the roles 'lead_instructor',
      'grader', 'student' and 'instructor'" do
    expect(CourseRole.count).to eq(4)
    expect(CourseRole.lead_instructor).not_to be_nil
    expect(CourseRole.grader).not_to be_nil
    expect(CourseRole.instructor).not_to be_nil
    expect(CourseRole.student).not_to be_nil
  end  

  describe "builtin roles" do
    let(:builtin_role) { CourseRole.lead_instructor }

    subject { builtin_role }

    it { should respond_to(:can_manage_course) }
    it { should respond_to(:can_manage_assignments) }
    it { should respond_to(:can_grade_submissions) }
    it { should respond_to(:can_view_other_submissions) }

    it "can not be deleted" do
      expect { builtin_role.destroy }.not_to change(CourseRole, :count)
    end

    describe "'s properties should not be update-able" do
      before do
        builtin_role.update(can_manage_course: false)
        builtin_role.update(can_manage_assignments: false)
        builtin_role.update(can_grade_submissions: false)
        builtin_role.update(can_view_other_submissions: false)
        builtin_role.reload
      end

      its(:can_manage_course ) { should eq(true) }
      its(:can_manage_assignments ) { should eq(true) }
      its(:can_grade_submissions ) { should eq(true) }
      its(:can_view_other_submissions ) { should eq(true) }

    end

    describe "lead instructor" do
      let(:lead_instructor) { CourseRole.lead_instructor }
      subject { lead_instructor }

      its(:can_manage_course ) { should eq(true) }
      its(:can_manage_assignments ) { should eq(true) }
      its(:can_grade_submissions ) { should eq(true) }
      its(:can_view_other_submissions ) { should eq(true) }
    end

    describe "instructor" do
      let(:instructor) { CourseRole.instructor }
      subject { instructor }

      its(:can_manage_course ) { should eq(false) }
      its(:can_manage_assignments ) { should eq(true) }
      its(:can_grade_submissions ) { should eq(true) }
      its(:can_view_other_submissions ) { should eq(true) }
    end

    describe "grader" do
      let(:grader) { CourseRole.grader }
      subject { grader }

      its(:can_manage_course ) { should eq(false) }
      its(:can_manage_assignments ) { should eq(false) }
      its(:can_grade_submissions ) { should eq(true) }
      its(:can_view_other_submissions ) { should eq(true) }
    end
    
    describe "student" do
      let(:student) { CourseRole.student }
      subject { student }

      its(:can_manage_course ) { should eq(false) }
      its(:can_manage_assignments ) { should eq(false) }
      its(:can_grade_submissions ) { should eq(false) }
      its(:can_view_other_submissions ) { should eq(false) }
    end
  end

  describe "when name is not present" do
    before { course_role.name = "" }
    it { should be_invalid }
  end

  describe "when name is not unique" do
    let!(:new_user) { FactoryGirl.create(:course_role) }

    it do
      should be_invalid
    end

    after { new_user.destroy }
  end

  describe ".staff" do
    specify { expect(CourseRole.student).not_to be_staff }
    specify { expect(course_role).not_to be_staff }
    specify { expect(CourseRole.grader).to be_staff }
    specify { expect(CourseRole.lead_instructor).to be_staff }
    specify { expect(CourseRole.instructor).to be_staff }
  end

  describe ".order_number" do
    specify { expect(CourseRole.lead_instructor.order_number).to be(8|4|2|1) }
    specify { expect(CourseRole.instructor.order_number).to be(4|2|1) }
    specify { expect(CourseRole.grader.order_number).to be(2|1) }
    specify { expect(CourseRole.student.order_number).to be(0) }
  end

end
