require "test_helper"

class SubscriptionObserverTest < ActiveSupport::TestCase
  def setup
    @user = create(:user, role: :student)
    @teacher_membership = create(:membership, name: "Docenten")
    @student_membership = create(:membership, name: "Basis")
    @other_membership = create(:membership, name: "Unknown")
  end

  test "does nothing if user is admin" do
    admin = create(:user, role: :admin)
    SubscriptionObserver.call(admin)
    assert_equal "admin", admin.reload.role
  end

  test "sets role to teacher if user has active Docenten membership" do
    create(:subscription, user: @user, membership: @teacher_membership, status: "active")
    SubscriptionObserver.call(@user)
    assert_equal "teacher", @user.reload.role
  end

  test "sets role to student if user has active Basis membership" do
    create(:subscription, user: @user, membership: @student_membership, status: "active")
    SubscriptionObserver.call(@user)
    assert_equal "student", @user.reload.role
  end

  test "sets role to inactive if user has active subscription with unknown membership" do
    create(:subscription, user: @user, membership: @other_membership, status: "active")
    SubscriptionObserver.call(@user)
    assert_equal "inactive", @user.reload.role
  end

  test "sets role to inactive if user has no active subscriptions" do
    create(:subscription, user: @user, membership: @student_membership, status: "canceled")
    SubscriptionObserver.call(@user)
    assert_equal "inactive", @user.reload.role
  end
end
