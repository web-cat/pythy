require 'test_helper'

class ActivityLogsControllerTest < ActionController::TestCase
  setup do
    @activity_log = activity_logs(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:activity_logs)
  end

end
