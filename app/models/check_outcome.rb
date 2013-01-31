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
    # Putting a $ at the end of the custom hint message for the
    # assertion will indicate that the rest of the message should
    # not be shown to the student.
    r = detail['reason']
    if r && r =~ /(.*)\$:.*/
      $1
    else
      r
    end
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