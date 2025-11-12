require "test_helper"

class UserTest < ActiveSupport::TestCase
  def setup
    @user = User.new(
      email: "test@example.com",
      password: "securepassword", password_confirmation: "securepassword"
    )
  end

  test "正常系: 有効なユーザー" do
  assert @user.valid?
  end

  test "異常系: メールアドレスが空欄" do
    user = User.new(email: "", password: "password", password_confirmation: "password")
    assert_not user.valid?
    assert_includes user.errors[:email], "を入力してください"
  end

  test "異常系: メールアドレスが重複" do
    @user.save!
    duplicate_email_user = User.new(
      email: @user.email,
      password: "anotherpassword",
      password_confirmation: "anotherpassword"
    )
    assert_not duplicate_email_user.valid?
    assert_includes duplicate_email_user.errors[:email], "はすでに存在します"
  end

  test "異常系: パスワードが空欄（新規作成時）" do
    user = User.new(email: "test@example.com", password: "", password_confirmation: "")
    assert_not user.valid?
    assert_includes user.errors[:password], "を入力してください"
  end

  test "メールアドレスの正規化: 保存前に小文字化される" do
    user = User.create!(
      email: "  TEST@Example.COM  ",
      password: "password",
      password_confirmation: "password"
    )

    assert_equal "test@example.com", user.email
  end
end
