require 'test_helper'

class AssignmentOfferingsControllerTest < ActionController::TestCase
  setup do
    @assignment_offering = assignment_offerings(:cs1064_p1_98765)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:assignment_offerings)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create assignment_offering" do
    assert_difference('AssignmentOffering.count') do
      post :create, :assignment_offering => { :assignment_id => @assignment_offering.assignment_id, :course_offering_id => @assignment_offering.course_offering_id, :due_at => @assignment_offering.due_at, :published => @assignment_offering.published }
    end

    assert_redirected_to assignment_offering_path(assigns(:assignment_offering))
  end

  test "should show assignment_offering" do
    get :show, :id => @assignment_offering
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @assignment_offering
    assert_response :success
  end

  test "should update assignment_offering" do
    put :update, :id => @assignment_offering, :assignment_offering => { :assignment_id => @assignment_offering.assignment_id, :course_offering_id => @assignment_offering.course_offering_id, :due_at => @assignment_offering.due_at, :published => @assignment_offering.published }
    assert_redirected_to assignment_offering_path(assigns(:assignment_offering))
  end

  test "should destroy assignment_offering" do
    assert_difference('AssignmentOffering.count', -1) do
      delete :destroy, :id => @assignment_offering
    end

    assert_redirected_to assignment_offerings_path
  end
end
