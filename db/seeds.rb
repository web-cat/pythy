# Populates the database with a set of default data necessary for proper
# operation

# Create a the two default roles -- these are both required
# for user creation
GlobalRole.create!(:can_edit_system_configuration => true, 
                    :can_manage_all_courses => true,
                    :can_manage_own_courses => true,
                    :builtin => true,
                    :name => "Administrator")

GlobalRole.create!(:can_edit_system_configuration => false, 
                    :can_manage_all_courses => false,
                    :can_manage_own_courses => false,
                    :builtin => true,
                    :name => "Student")

# The instructor role is not required, but is handy in practice
GlobalRole.create!(:can_edit_system_configuration => false, 
                    :can_manage_all_courses => false,
                    :can_manage_own_courses => true,
                    :builtin => true,
                    :name => "Instructor")
