require "test_helper"

# テスト用に OauthController#get_access_token を上書きする
class ::OauthController
  private

  def get_access_token(code)
    # 本番では外部APIを叩いていたが、
    # テストでは固定値を返すようにする
    "dummy-token-123"
  end
end

class OauthControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
    log_in_as(@user)
  end

  test "GET /oauth/callback: codeからアクセストークンを取得してセッションに保存し、photosへリダイレクトする" do
    get oauth_callback_path, params: { code: "auth-code-xyz" }

    assert_redirected_to photos_path
    assert_equal "外部サービスとの連携が完了しました", flash[:notice]
    assert_equal "dummy-token-123", @request.session[:oauth_access_token]
  end

  private

  def log_in_as(user)
    post login_path, params: { email: user.email, password: "password123" }
    assert_response :redirect
  end
end
