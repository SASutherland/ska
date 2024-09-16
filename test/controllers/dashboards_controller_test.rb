require "test_helper"

class DashboardsControllerTest < ActionDispatch::IntegrationTest
  test "should get index" do
    get dashboard_url
    assert_response :success
  end
end
