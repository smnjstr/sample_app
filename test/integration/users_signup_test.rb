require 'test_helper'

class UsersSignupTest < ActionDispatch::IntegrationTest

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
  test "valid signup information" do
    get signup_path
    assert_difference 'User.count', 1 do 
      post users_path, params: { user: { name: "name valid",
                                         email: "user@valid.com",
                                         password: "password",
                                         password_confirmation: "password" } }
    end
    follow_redirect!
    assert_template 'users/show'
    assert_equal 'Welcome to our community!', flash[:success]
    assert is_logged_in?
  end
  

end
