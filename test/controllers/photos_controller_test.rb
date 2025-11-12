require "test_helper"

class PhotosControllerTest < ActionDispatch::IntegrationTest
  test "未ログインは /photos にアクセスできずリダイレクト" do
    get photos_path
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal "ログインしてください", flash[:alert]
  end
end
