require 'test_helper'

class TermTest < ActiveSupport::TestCase

  def setup
  	@spring2013 = terms(:spring2013)
  end

  # Verify Term.contains? using a Date argument
  test "should contain date in term" do
  	assert @spring2013.contains?(Date.parse('2013-03-01'))
  end

  test "should not contain date of day before term starts" do
  	assert !@spring2013.contains?(Date.parse('2013-01-15'))
  end

  test "should contain date term starts" do
  	assert @spring2013.contains?(Date.parse('2013-01-16'))
  end

  test "should not contain date term ends" do
  	assert !@spring2013.contains?(Date.parse('2013-05-15'))
  end

  # Verify Term.contains? using a DateTime argument
  test "should contain datetime in term" do
  	assert @spring2013.contains?(DateTime.parse('2013-03-01 17:00:00'))
  end

  test "should not contain datetime of minute before term starts" do
  	assert !@spring2013.contains?(DateTime.parse('2013-01-15 23:59:59'))
  end

  test "should contain datetime of minute that term starts" do
  	assert @spring2013.contains?(DateTime.parse('2013-01-16 00:00:00'))
  end

  test "should contain datetime of minute before term ends" do
  	assert @spring2013.contains?(DateTime.parse('2013-05-14 23:59:59'))
  end

  test "should not contain datetime of minute that term ends" do
  	assert !@spring2013.contains?(DateTime.parse('2013-05-15 00:00:00'))
  end

end
