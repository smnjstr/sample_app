require 'test_helper'

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(name: "Example User", email: "user@example.com")
  end

# Test validity
  test "should be valid" do
    assert @user.valid?  
  end

# Test presence, aka not blank, assert invalid
  test "name should be present" do
    @user.name = "      "
    assert @user.invalid?
  end
  
  test "email should be present" do
    @user.email = "      "
    assert @user.invalid?
  end
  
# Test length is not to long, assert invalid
  test "name should not be to long" do
    @user.name = "a" * 51
    assert @user.invalid?
  end

  test "email should not be to long" do
    @user.email = "a" * 244 + "@example.com"
    assert @user.invalid?
  end
  
# Test for valid and invalid email format, assert valid and invalid
  test "email validation should accept valid addresses" do
    valid_addresses = %w[user@example.com USER@foo.COM A_US-ER@foo.bar.org
                         first.last@foo.jp alice+bob@baz.cn]
    valid_addresses.each do |valid_address|
      @user.email = valid_address
      assert @user.valid?, "#{valid_address.inspect} should be valid"
    end
  end
 
  test "email validation should reject invalid addresses" do
    invalid_addresses = %w[user@example,com user_at_foo.org user.name@example.
                           foo@bar_baz.com foo@bar+baz.com foo@bar..com]
    invalid_addresses.each do |invalid_address|
      @user.email = invalid_address
      assert @user.invalid?, "#{invalid_address.inspect} should be invalid"
    end
  end  

# Test for previous registered duplicate user email, assert invalid
  test "email address should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert duplicate_user.invalid?
  end
  
    test "saved email address should be lowercase" do
    mixed_case_email = "FooBaR@ExaMPLE.CoM"
    @user.email = mixed_case_email
    @user.save
    assert mixed_case_email.downcase == @user.reload.email  #could uas assert_equal
  end

end