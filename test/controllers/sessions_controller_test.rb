require "test_helper"

class SessionsControllerTest < ActionDispatch::IntegrationTest
  def setup
  @user = User.create(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "POST /login 成功の場合" do
    post login_path, params: { email: @user.email, password: "password123" }
    assert_response 302
    assert_redirected_to photos_path
  end

  test "POST /login 失敗の場合" do
    post login_path, params: { email: @user.email, password: "wrongpassword" }
    assert_response 422
    assert_includes @response.body, "メールアドレスまたはパスワードが違います"
  end

  test "DELETE /logout ログアウト" do
    # ログインする
    post login_path, params: { email: @user.email, password: "password123" }

    delete logout_path
    assert_redirected_to login_path
  end
end
