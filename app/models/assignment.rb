class Assignment < ActiveRecord::Base

  belongs_to  :creator, class_name: "User"
  belongs_to  :course

  has_many    :assignment_offerings
  has_one     :assignment_reference_repository

  attr_accessible :creator_id, :long_name, :short_name,
    :brief_summary, :description, :assignment_offerings_attributes

  accepts_nested_attributes_for :assignment_offerings

  validates :short_name, presence: true
  validates :long_name, presence: true

  before_validation :set_url_part
  after_create :create_reference_repository


  # -------------------------------------------------------------
  def set_url_part
    self.url_part = url_part_safe(short_name)
  end


  # -------------------------------------------------------------
  def brief_summary_html(options = {})
    summary = brief_summary

    if options[:link] && !description.blank?
      summary.sub! /\n*$/, " <a href='#{options[:link]}' target='_blank'>(Click here to open the full description in a new tab.)</a>"
    end

    @brief_summary_html ||= markdown_renderer.render(summary)
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


  # -------------------------------------------------------------
  def create_reference_repository
    AssignmentReferenceRepository.create(
      assignment_id: id,
      user_id: creator.id)
  end

end
