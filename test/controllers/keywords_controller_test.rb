require 'test_helper'

class KeywordsControllerTest < ActionDispatch::IntegrationTest
  test "should get show" do
    get keywords_show_url
    assert_response :success
  end

  test "should get index" do
    get keywords_index_url
    assert_response :success
  end

end
