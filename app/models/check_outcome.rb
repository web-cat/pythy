class CheckOutcome < ActiveRecord::Base

  belongs_to :assignment_check

  attr_accessible :name, :category, :position, :score, :possible_score


  # -------------------------------------------------------------
  def percentage_score
    100 * score / possible_score
  end

end