require 'test_helper'

class MicropostTest < ActiveSupport::TestCase

  def setup
    @user = users(:alexander)
    # You build micropost through association between models
    @micropost = @user.microposts.build(content: "Lorem ipsum")
  end

  test "should be valid" do
    assert @micropost.valid?
  end
  
  test "user id should be present" do
    @micropost.user_id = nil
    assert !@micropost.valid?
  end

  test "content should be present" do
    @micropost.content = "     "
    assert !@micropost.valid?
  end
  
  test "content should be at most 140 characters" do
    @micropost.content = "a" * 141
    assert !@micropost.valid?
  end
  
  test "order should be most recent first" do
    assert_equal microposts(:most_recent), Micropost.first
  end
  
end
