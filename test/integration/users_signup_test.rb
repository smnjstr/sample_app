require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

def setup
  ActionMailer::Base.deliveries.clear
end

# Test invalid signup fails safely

  test "invalid signup information" do
    get signup_path
    assert_no_difference 'User.count' do 
      post users_path, params: { user: { name: "",
                                         email: "user@invalid",
                                         password: "foo",
                                         password_confirmation: "bar" } }
    end
    assert_template 'users/new'
    assert_select 'div#error_explanation'       # book solution
    assert_select 'div.field_with_errors'       # book solution
  end

  test "error messages should be triggered" do
    @user = User.create(name: "",
                        email: "user@invalid",
                        password: "foo",
                        password_confirmation: "bar")
    assert @user.errors.full_messages.empty?.!  # my solution
  end

# Test valid signup
  test "valid signup information with account activation" do
    get signup_path
    assert_difference 'User.count', 1 do 
      post users_path, params: { user: { name: "name valid",
                                         email: "user@valid.com",
                                         password: "password",
                                         password_confirmation: "password" } }
    end
    
    assert_equal 1, ActionMailer::Base.deliveries.size
    user = assigns(:user)
    assert !user.activated
    # Try to log in before activation
    log_in_as(user)
    assert !is_logged_in?
    # Invalid activation token, correct email
    get edit_account_activation_path("invalid token", email: user.email)
    assert !is_logged_in?
    # Valid token, incorrect email
    get edit_account_activation_path(user.activation_token, email: 'wrong')
    assert !is_logged_in?
    # Valid activation token and email
    get edit_account_activation_path(user.activation_token, email: user.email)
    assert user.reload.activated?
    follow_redirect!
    assert_template 'users/show'
    assert is_logged_in?
  end
end
