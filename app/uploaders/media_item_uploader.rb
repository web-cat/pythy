# encoding: utf-8

class MediaItemUploader < CarrierWave::Uploader::Base

  # Include RMagick or MiniMagick support:
  # include CarrierWave::RMagick
  include CarrierWave::MiniMagick
  include CarrierWave::MimeTypes

  # Choose what kind of storage to use for this uploader:
  storage :file
  # storage :fog

  # -------------------------------------------------------------
  # Override the directory where uploaded files will be stored.
  # See in media_controller.rb that we overwrite files with the same name
  # instead of adding them with a different idea, so the mount location
  # below is safe even though it doesn't contain the MediaItem id.
  def store_dir
    if model.assignment
      "m/a/#{model.assignment.resource_key}"
    elsif model.user
      "m/u/#{model.user.resource_key}"
    else
      nil
    end
  end

  # Provide a default URL as a default if there hasn't been a file uploaded:
  # def default_url
  #   # For Rails 3.1+ asset pipeline compatibility:
  #   # asset_path("fallback/" + [version_name, "default.png"].compact.join('_'))
  #
  #   "/images/fallback/" + [version_name, "default.png"].compact.join('_')
  # end

  # Process files as they are uploaded:
  process :set_content_type

  # Create different versions of your uploaded files:
  version :thumb, if: :image? do
    process :efficient_conversion => [64, 64]

    def full_filename(for_file)
      dir_only = File.dirname(for_file)
      file_only = File.basename(for_file)
      file_only.sub!(/\.[^.]+\z/, '_thumb.png')
      File.join(dir_only, '_thumbs', file_only)
    end 
  end

  process :set_size_in_model, if: :image?

  # -------------------------------------------------------------
  # Add a white list of extensions which are allowed to be uploaded.
  # For images you might use something like this:
  def extension_white_list
    %w(
      jpg jpeg gif png
      txt csv
      wav mp3
    )
  end


  protected

  # -------------------------------------------------------------
  def set_content_type
    super
    file.content_type = 'application/octet-stream' if file.content_type.blank?
  end


  # -------------------------------------------------------------
  def image?(new_file)
    new_file.content_type.start_with? 'image'
  end


  # -------------------------------------------------------------
  def efficient_conversion(width, height)
    manipulate! do |img|
      img.format('png') do |c|
        c.fuzz        '3%'
        c.trim
        c.resize      "#{width}x#{height}>"
        c.resize      "#{width}x#{height}<"
      end
      img
    end
  end


  # -------------------------------------------------------------
  def set_size_in_model
    image = MiniMagick::Image.open(file.path)
    model.info[:width] = image[:width]
    model.info[:height] = image[:height]
  end

end
