require 'test_helper'

class UserShowTest < ActionDispatch::IntegrationTest

  def setup
    @activated_user     = users(:alexander)
    @not_activated_user = users(:inactive)
  end
  
  test "should redirect when user not activated" do
    get user_path(@not_activated_user)
    assert_response :redirect
    assert_redirected_to root_url
  end
  
  test "should display user when activated" do
    get user_path(@activated_user)
    assert_response :success
    assert_template 'users/show'
  end
  
end
