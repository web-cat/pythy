class PathValidator < ActiveModel::Validator
  def validate(system_configuration)
    storage_dir = find_writable_path(system_configuration.storage_path)
    work_dir = find_writable_path(system_configuration.work_path)

    # Returns an error if there is no such path or if the user
    # doesn't have permission to write to the path
    unless File.exists?(storage_dir) and File.stat(storage_dir).writable? 
      system_configuration.errors[:storage_path_permission_denied] <<
        "Storage path must be writable by the server."
    end
    unless File.exists?(work_dir) and File.stat(work_dir).writable?
      system_configuration.errors[:work_path_permission_denied] <<
        "Work path must be writable by the server."
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
