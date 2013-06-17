require 'test_helper'

class OrganizationsControllerTest < ActionController::TestCase
  setup do
    @organization = organizations(:vt)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:organizations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create organization" do
    assert_difference('Organization.count') do
      post :create, :organization => { :display_name => @organization.display_name, :domain => @organization.domain }
    end

    assert_redirected_to organization_path(assigns(:organization))
  end

  test "should show organization" do
    get :show, :id => @organization
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @organization
    assert_response :success
  end

  test "should update organization" do
    put :update, :id => @organization, :organization => { :display_name => @organization.display_name, :domain => @organization.domain }
    assert_redirected_to organization_path(assigns(:organization))
  end

  test "should destroy organization" do
    assert_difference('Organization.count', -1) do
      delete :destroy, :id => @organization
    end

    assert_redirected_to organizations_path
  end
end
