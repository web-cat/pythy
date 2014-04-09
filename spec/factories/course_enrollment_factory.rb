FactoryGirl.define do
  factory :course_enrollment, class: CourseEnrollment do
    user
    course_offering
    course_role
  end
end
