class Assignment < ActiveRecord::Base

  belongs_to  :creator, class_name: "User"
  belongs_to  :course

  has_many    :assignment_offerings

  attr_accessible :creator_id, :long_name, :short_name, :description,
    :assignment_offerings_attributes

  accepts_nested_attributes_for :assignment_offerings

  validates :short_name, presence: true
  validates :long_name, presence: true

  before_validation :set_url_part


  # -------------------------------------------------------------
  def set_url_part
    self.url_part = url_part_safe(short_name)
  end


  # -------------------------------------------------------------
  def brief_summary_html
    @brief_summary_html ||= markdown_renderer.render(brief_summary)
  end


  # -------------------------------------------------------------
  def description_html
    @description_html ||= markdown_renderer.render(description)
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

end
