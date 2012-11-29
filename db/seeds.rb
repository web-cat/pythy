# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Emanuel', :city => cities.first)

GlobalRole.create!(:can_edit_system_configuration => true, 
                    :can_manage_all_courses => true,
                    :can_manage_own_courses => true,
                    :description => '', 
                    :name => "Administrator")