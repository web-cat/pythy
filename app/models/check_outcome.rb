class CheckOutcome < ActiveRecord::Base

  belongs_to :assignment_check

  attr_accessible :name, :description, :category, :position, :score,
    :possible_score, :detail

  serialize :detail, Hash


  # -------------------------------------------------------------
  def percentage_score
    100 * score / possible_score
  end


  # -------------------------------------------------------------
  def hint?
    detail['reason'] && detail['reason'] =~ /Hint:/i
  end


  # -------------------------------------------------------------
  def hint
    if detail['reason'] && detail['reason'] =~ /Hint:\s*(.*)$/i
      $1
    end
  end

end