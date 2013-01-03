require 'test_helper'

class SystemConfigurationsControllerTest < ActionController::TestCase
  setup do
    @system_configuration = system_configurations(:one)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:system_configurations)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create system_configuration" do
    assert_difference('SystemConfiguration.count') do
      post :create, system_configuration: { storage_path: @system_configuration.storage_path }
    end

    assert_redirected_to system_configuration_path(assigns(:system_configuration))
  end

  test "should show system_configuration" do
    get :show, id: @system_configuration
    assert_response :success
  end

  test "should get edit" do
    get :edit, id: @system_configuration
    assert_response :success
  end

  test "should update system_configuration" do
    put :update, id: @system_configuration, system_configuration: { storage_path: @system_configuration.storage_path }
    assert_redirected_to system_configuration_path(assigns(:system_configuration))
  end

  test "should destroy system_configuration" do
    assert_difference('SystemConfiguration.count', -1) do
      delete :destroy, id: @system_configuration
    end

    assert_redirected_to system_configurations_path
  end
end
