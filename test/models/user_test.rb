require 'test_helper'

class UserTest < ActiveSupport::TestCase

  def setup
    @user = User.new(name: "Example User", email: "user@example.com",
                     password: "foobar", password_confirmation: "foobar")
  end
  
  test "should be valid" do
    assert @user.valid?
  end

  test "name should be present" do
    @user.name = ""
    assert_not @user.valid?
  end

  test "email should be present" do
    @user.email = "     "
    assert_not @user.valid?
  end

  test "name should not be too long" do
    @user.name = "a" * 51
    assert_not @user.valid?
  end

  test "email should not be too long" do
    @user.email = "a" * 244 + "@example.com"
    assert_not @user.valid?
  end

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
      assert !@user.valid?, "#{invalid_address.inspect} should be invalid"
    end
  end

  test "email addresses should be unique" do
    duplicate_user = @user.dup
    @user.save
    assert_not duplicate_user.valid?
  end

  test "password should be present (nonblank)" do
    @user.password = @user.password_confirmation = " " * 6
    assert_not @user.valid?
  end

  test "password should have a minimum length" do
    @user.password = @user.password_confirmation = "a" * 5
    assert_not @user.valid?
  end

  test "authenticated? should return false for a user with nil digest" do
    assert_not @user.authenticated?(:remember, '')
  end
  
  test "assocaited mocroposts should be destroyed" do
    @user.save
    @user.microposts.create!(content: "Lorem ipsum")
    assert_difference 'Micropost.count', -1 do
      @user.destroy
    end
  end  
  
  test "should follow and unfollow a user" do
    alexander = users(:alexander)
    betty = users(:betty)
    assert !alexander.following?(betty)
    alexander.follow(betty)
    assert alexander.following?(betty)
    assert betty.followers.include?(alexander)
    alexander.unfollow(betty)
    assert !alexander.following?(betty)
    alexander.follow(alexander)
    assert !alexander.following?(alexander)
  end
  
    test "feed should have the right posts" do
    alexander = users(:alexander)
    betty  = users(:betty)
    lana    = users(:lana)
    # Posts from followed user
    lana.microposts.each do |post_following|
      assert alexander.feed.include?(post_following)
    end
    # Self-posts for user with followers
    alexander.microposts.each do |post_self|
      assert alexander.feed.include?(post_self)
    end
    # Self-posts for user with no followers
    betty.microposts.each do |post_self|
      assert betty.feed.include?(post_self)
      assert_equal alexander.feed.distinct, alexander.feed
    end
    # Posts from unfollowed user
    betty.microposts.each do |post_unfollowed|
      assert_not alexander.feed.include?(post_unfollowed)
    end
  end

  
  
end