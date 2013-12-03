class Assignment < ActiveRecord::Base

  belongs_to  :creator, class_name: "User"
  belongs_to  :course
  belongs_to :term

  has_many    :assignment_offerings
  has_one     :assignment_reference_repository

  attr_accessible :creator_id, :long_name, :short_name,
    :brief_summary, :description, :assignment_offerings_attributes

  accepts_nested_attributes_for :assignment_offerings

  after_create :create_reference_repository

  validates :url_part, uniqueness: { scope: :course_id,
    message: 'cannot collide with the URL for another assignment in the same course' }
  validates :short_name, presence: true
  validates :long_name, presence: true


  # -------------------------------------------------------------
  def set_url_part
    new_url_part = url_part_safe(short_name)
    if self.url_part != new_url_part    
      existing_urls = self.term.assignments
      existing_urls.where!("id != ?", self.id) if self.id
      existing_urls = existing_urls.pluck(:url_part)
      
      i = 2    
      self.url_part = new_url_part
      while existing_urls.include?(self.url_part)
        self.url_part = new_url_part
        self.url_part += "_" + i.to_s
        i += 1
      end
    end
    self.save
  end


  # -------------------------------------------------------------
  def brief_summary_html(options = {})
    summary = brief_summary
    
    if summary.nil?
      summary = ""
    end

    if options[:link] && !description.blank?
      summary.sub!(/\n*$/, " <a href='#{options[:link]}' target='_blank'>(Click here to open the full description in a new tab.)</a>")
    end

    @brief_summary_html ||= markdown_renderer.render(summary)
  end


  # -------------------------------------------------------------
  def description_html
    @description_html ||= markdown_renderer.render(description)
  end


  # -------------------------------------------------------------
  def can_view_submissions_for_any_offering?(user)
    assignment_offerings.any? do |ao|
      co = ao.course_offering
      co.role_for_user(user).can_view_other_submissions? if co.role_for_user(user)
    end
  end


  private

  # -------------------------------------------------------------
  def markdown_renderer
    @markdown ||= Redcarpet::Markdown.new(Redcarpet::Render::HTML,
      no_intra_emphasis: true,
      tables: true,
      fenced_code_blocks: true,
      autolink: true,
      strikethrough: true,
      superscript: true)
  end


  # -------------------------------------------------------------
  def create_reference_repository
    set_url_part
    
    AssignmentReferenceRepository.create(
      assignment_id: id,
      user_id: creator.id,
      term_id: term_id)
  end

end
