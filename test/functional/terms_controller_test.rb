require 'test_helper'

class TermsControllerTest < ActionController::TestCase
  setup do
    @term = terms(:spring2013)
  end

  test "should get index" do
    get :index
    assert_response :success
    assert_not_nil assigns(:terms)
  end

  test "should get new" do
    get :new
    assert_response :success
  end

  test "should create term" do
    assert_difference('Term.count') do
      post :create, :term => { :ends_on => @term.ends_on, :season => @term.season, :starts_on => @term.starts_on, :year => @term.year }
    end

    assert_redirected_to term_path(assigns(:term))
  end

  test "should show term" do
    get :show, :id => @term
    assert_response :success
  end

  test "should get edit" do
    get :edit, :id => @term
    assert_response :success
  end

  test "should update term" do
    put :update, :id => @term, :term => { :ends_on => @term.ends_on, :season => @term.season, :starts_on => @term.starts_on, :year => @term.year }
    assert_redirected_to term_path(assigns(:term))
  end

  test "should destroy term" do
    assert_difference('Term.count', -1) do
      delete :destroy, :id => @term
    end

    assert_redirected_to terms_path
  end
end
