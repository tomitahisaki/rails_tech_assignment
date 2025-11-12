require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  test "正常系: 有効な写真" do
    photo = Photo.new(title: "Sample Photo")
    assert photo.valid?
  end

  test "異常系: タイトルが空欄の場合" do
    photo = Photo.new(title: "")
    assert_not photo.valid?
    assert_includes photo.errors[:title], "を入力してください"
  end

  test "異常系: タイトルが30文字の場合" do
    photo = Photo.new(title: "a" * 30)
    assert photo.valid?
  end

  test "異常系: タイトルが31文字の場合" do
    photo = Photo.new(title: "a" * 31)
    assert_not photo.valid?
    assert_includes photo.errors[:title], "は30文字以内で入力してください"
  end
end
