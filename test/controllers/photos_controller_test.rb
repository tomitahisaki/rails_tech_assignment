require "test_helper"

class PhotosControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "未ログインは /photos にアクセスできずリダイレクト" do
    get photos_path
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal "ログインしてください", flash[:alert]
  end

  test "ログイン済みユーザーは一覧ページを表示できる" do
    # ログイン処理
    post login_path, params: {
      email: @user.email,
      password: "password123"
    }

    # follow_redirect!  # root_path にリダイレクトされる想定（必要なら）

    # 一覧ページにアクセス
    get photos_path
    assert_response :success
    assert_select "h1", "写真一覧"
  end
end
