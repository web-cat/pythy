include ActionView::Helpers::NumberHelper

class MediaItem < ActiveRecord::Base

  belongs_to :user

  belongs_to :assignment

  attr_accessible :user_id, :assignment_id, :file, :info, :content_type,
                  :file_size

  serialize :info, Hash

  mount_uploader :file, MediaItemUploader

  before_save :update_file_attributes

  validate :validate_file_size


  # -------------------------------------------------------------
  def filename
    File.basename(file.url)
  end


  # -------------------------------------------------------------
  def image?
    content_type && content_type.start_with?('image')
  end


  # -------------------------------------------------------------
  def audio?
    content_type && content_type.start_with?('audio')
  end


  # -------------------------------------------------------------
  def text?
    content_type && content_type.start_with?('text')
  end


  # -------------------------------------------------------------
  def as_json(options)
    # TODO handle non-image types

    thumb_url = file_url(:thumb)
    info_text = ''

    if image?
      info_text = "#{info[:width]} x #{info[:height]}, "
    elsif audio?
      thumb_class = 'music'
    elsif text?
      thumb_class = 'file-alt'
    else
      thumb_class = 'file'
    end

    info_text += "#{number_to_human_size(file_size)}"

    super(options.merge(methods: :filename)).merge({
      thumbnail_url: thumb_url,
      thumbnail_class: thumb_class,
      info_text: info_text
    })
  end


  private

  # -------------------------------------------------------------
  def update_file_attributes
    if file.present? && file_changed?
      self.content_type = file.file.content_type
      self.file_size = file.file.size
    end    
  end


  # -------------------------------------------------------------
  def validate_file_size
    if file.present?
      if user
        # TODO make this configurable
        if file.file.size.to_f > 1.megabyte
          errors.add(:file, "You cannot upload a file greater than 1MB")
        end

        bytes_used = MediaItem.where(user_id: user.id).sum(:file_size)
        bytes_used += file.file.size.to_f

        if bytes_used > 10.megabytes
          errors.add(:file, "You have exceeded your 10MB limit on uploaded files")
        end
      end
    end
  end

end
