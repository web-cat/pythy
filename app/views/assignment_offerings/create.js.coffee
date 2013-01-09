$('#assignment_offerings').html(
  '<%= j render(@course_offering.assignment_offerings) %>')

$('#assignment_offerings_modal').modal('hide')
