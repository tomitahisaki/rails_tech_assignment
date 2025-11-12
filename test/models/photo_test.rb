require "test_helper"

class PhotoTest < ActiveSupport::TestCase
  test "正常系: 有効な写真" do
    photo = Photo.new(title: "Sample Photo")
    photo.image.attach(
      io: File.open(file_fixture("sample_image.png")),
      filename: "sample_image.png",
      content_type: "image/png"
      )

    assert photo.valid?
  end

  test "異常系: タイトルが空欄の場合" do
    photo = Photo.new(title: "")
    photo.image.attach(
      io: File.open(file_fixture("sample_image.png")),
      filename: "sample_image.png",
      content_type: "image/png"
      )
    assert_not photo.valid?
    assert_includes photo.errors[:title], "を入力してください"
  end

  test "異常系: タイトルが30文字の場合" do
    photo = Photo.new(title: "a" * 30)
    photo.image.attach(
      io: File.open(file_fixture("sample_image.png")),
      filename: "sample_image.png",
      content_type: "image/png"
      )
    assert photo.valid?
  end

  test "異常系: タイトルが31文字の場合" do
    photo = Photo.new(title: "a" * 31)
    photo.image.attach(
      io: File.open(file_fixture("sample_image.png")),
      filename: "sample_image.png",
      content_type: "image/png"
      )
    assert_not photo.valid?
    assert_includes photo.errors[:title], "は30文字以内で入力してください"
  end

  test "異常系: 画像が添付されていない場合" do
    photo = Photo.new(title: "Sample Photo")
    assert_not photo.valid?
    assert_includes photo.errors[:image], "を添付してください"
  end
end
