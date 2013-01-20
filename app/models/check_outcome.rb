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
  def reason
    detail['reason']
  end


  # -------------------------------------------------------------
  def hint?
    reason && reason =~ /Hint:/i
  end


  # -------------------------------------------------------------
  def hint
    if reason && reason =~ /Hint:\s*(.*)$/i
      $1
    end
  end

end