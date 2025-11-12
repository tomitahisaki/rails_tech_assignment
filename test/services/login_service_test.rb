require "test_helper"

class LoginServiceTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com", password: "password", password_confirmation: "password")
  end

  test "メール未入力でエラーを返す" do
    s = LoginService.new(email: "", password: "password")
    assert_not s.execute
    assert_includes s.errors[:email], "を入力してください"
  end

  test "パスワード未入力でエラーを返す" do
    s = LoginService.new(email: @user.email, password: "")
    assert_not s.execute
    assert_includes s.errors[:password], "を入力してください"
  end

  test "メール、パスワード未入力で両方のエラーを返す" do
    s = LoginService.new(email: "", password: "")
    assert_not s.execute
    assert_equal [
      "メールアドレスを入力してください",
      "パスワードを入力してください"
    ], s.errors.full_messages
  end

  test "認証したときは、エラーを返す" do
    s = LoginService.new(email: @user.email, password: "wrong")
    assert_not s.execute
    assert_includes s.errors[:base], "メールアドレスまたはパスワードが違います"
  end

  test "認証成功すると、trueを返す" do
    s = LoginService.new(email: @user.email, password: "password")
    assert s.execute
  end

  test "メールアドレスが大文字小文字混在でも認証成功する" do
    s = LoginService.new(email: "TEST@example.com", password: "password")
    assert s.execute
  end
end
