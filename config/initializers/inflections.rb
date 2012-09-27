# Be sure to restart your server when you modify this file.

# We use the word "staff" to refer to users who are teachers or
# graders on a course, so we add the inflection here to make sure
# that singular/plural automated conversions do the right thing
# (we don't want to have to write "staffs").
ActiveSupport::Inflector.inflections do |inflect|
  inflect.irregular 'staff', 'staff'
end
