require 'test_helper'

class DepartmentsControllerTest < ActionController::TestCase
  setup do
    @department = departments(:cs_at_vt)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:departments)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create department" do
    assert_difference('Department.count') do
      post :create, :department => { :abbreviation => @department.abbreviation, :institution_id => @department.institution_id, :name => @department.name }
    end

    assert_redirected_to department_path(assigns(:department))
  end

  test "should show department" do
    get :show, :id => @department
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @department
    assert_response :success
  end

  test "should update department" do
    put :update, :id => @department, :department => { :abbreviation => @department.abbreviation, :institution_id => @department.institution_id, :name => @department.name }
    assert_redirected_to department_path(assigns(:department))
  end

  test "should destroy department" do
    assert_difference('Department.count', -1) do
      delete :destroy, :id => @department
    end

    assert_redirected_to departments_path
  end
end
