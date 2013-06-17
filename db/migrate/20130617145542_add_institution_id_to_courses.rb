class AddInstitutionIdToCourses < ActiveRecord::Migration
  
  def change
    add_column :courses, :institution_id, :integer
    add_column :courses, :url_part, :string
  end

end
