require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  def setup
    @user = User.create!(email: "test@example.com", password: "securepassword", password_confirmation: "securepassword")
  end

  test "正常系: 有効な写真" do
    photo = Photo.new(title: "Sample Photo", user: @user)
    photo.image.attach(
      io: File.open(file_fixture("sample_image.png")),
      filename: "sample_image.png",
      content_type: "image/png"
      )

    assert photo.valid?
  end

  test "異常系: タイトルが空欄の場合" do
    photo = Photo.new(title: "", user: @user)
    photo.image.attach(
      io: File.open(file_fixture("sample_image.png")),
      filename: "sample_image.png",
      content_type: "image/png"
      )
    assert_not photo.valid?
    assert_includes photo.errors[:title], "を入力してください"
  end

  test "異常系: タイトルが30文字の場合" do
    photo = Photo.new(title: "a" * 30, user: @user)
    photo.image.attach(
      io: File.open(file_fixture("sample_image.png")),
      filename: "sample_image.png",
      content_type: "image/png"
      )
    assert photo.valid?
  end

  test "異常系: タイトルが31文字の場合" do
    photo = Photo.new(title: "a" * 31, user: @user)
    photo.image.attach(
      io: File.open(file_fixture("sample_image.png")),
      filename: "sample_image.png",
      content_type: "image/png"
      )
    assert_not photo.valid?
    assert_includes photo.errors[:title], "は30文字以内で入力してください"
  end

  test "異常系: 画像が添付されていない場合" do
    photo = Photo.new(title: "Sample Photo", user: @user)
    assert_not photo.valid?
    assert_includes photo.errors[:image], "を添付してください"
  end
end
