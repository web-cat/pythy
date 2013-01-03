class ExampleRepository < Repository

  belongs_to :course

  attr_accessible :name, :course_id

end
