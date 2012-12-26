# Populates the database with a set of default data necessary for proper
# operation

# Create a the two default roles -- these are both required
# for user creation
GlobalRole.delete_all
GlobalRole.create!(:can_edit_system_configuration => true, 
                    :can_manage_all_courses => true,
                    :can_create_courses => true,
                    :builtin => true,
                    :name => "Administrator")

GlobalRole.create!(:can_edit_system_configuration => false, 
                    :can_manage_all_courses => false,
                    :can_create_courses => false,
                    :builtin => true,
                    :name => "Student")

# The instructor role is not required, but is handy in practice
GlobalRole.create!(:can_edit_system_configuration => false, 
                    :can_manage_all_courses => false,
                    :can_create_courses => true,
                    :builtin => true,
                    :name => "Instructor")

# Create the default course roles
CourseRole.delete_all
CourseRole.create!(:can_manage_course => true,
                    :can_manage_assignments => true,
                    :can_grade_submissions => true,
                    :can_view_other_submissions => true,
                    :builtin => true,
                    :name => "Administrator (course)")

CourseRole.create!(:can_manage_course => false,
                    :can_manage_assignments => false,
                    :can_grade_submissions => false,
                    :can_view_other_submissions => false,
                    :builtin => true,
                    :name => "Student (course)")

CourseRole.create!(:can_manage_course => false,
                    :can_manage_assignments => true,
                    :can_grade_submissions => true,
                    :can_view_other_submissions => true,
                    :builtin => true,
                    :name => "Instructor (course)")
