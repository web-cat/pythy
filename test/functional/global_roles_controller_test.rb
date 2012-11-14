require 'test_helper'

class GlobalRolesControllerTest < ActionController::TestCase
  setup do
    @global_role = global_roles(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:global_roles)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create global_role" do
    assert_difference('GlobalRole.count') do
      post :create, global_role: {  }
    end

    assert_redirected_to global_role_path(assigns(:global_role))
  end

  test "should show global_role" do
    get :show, id: @global_role
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @global_role
    assert_response :success
  end

  test "should update global_role" do
    put :update, id: @global_role, global_role: {  }
    assert_redirected_to global_role_path(assigns(:global_role))
  end

  test "should destroy global_role" do
    assert_difference('GlobalRole.count', -1) do
      delete :destroy, id: @global_role
    end

    assert_redirected_to global_roles_path
  end
end
