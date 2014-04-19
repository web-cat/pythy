# Validates that the path exists and is writable by the server.
class PathValidator < ActiveModel::EachValidator
  def validate_each(record, attribute, value)
    dir = find_writable_path(value)

    if not File.exists?(dir)
      record.errors.add(attribute, "#{value} must exist.")
    end

    if not File.stat(dir).writable? 
      record.errors.add(attribute, "#{value} must be writable by the server.")
    end

  end
  
  private
    # Checks each path in the hierarchy to see if the path can be
    # written to by the user who started the server
    def find_writable_path(dir_path)
      paths = File.split(dir_path)

      while(!File.exists?(dir_path) ||
            !File.stat(dir_path).writable? &&
            !paths[0].eql?(paths[1])) do
        dir_path = paths[0]
        paths = File.split(dir_path)
      end

      return dir_path
    end
end
