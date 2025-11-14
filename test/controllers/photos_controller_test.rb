require "test_helper"

class PhotosControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )
  end

  test "GET /photos 未ログインは /photos にアクセスできずリダイレクト" do
    get photos_path
    assert_response :redirect
    assert_redirected_to login_path
    assert_equal "ログインしてください", flash[:alert]
  end

  test "GET /photos ログイン済みユーザーは一覧ページを表示できる" do
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


  test "POST /photos 未ログインは /photos にアクセスできずリダイレクト" do
    assert_no_difference "Photo.count" do
      post photos_path, params: {
        photo: { title: "unauth", image: uploaded_fixture("sample_image.png") }
      }
    end
    assert_redirected_to login_path
  end

  test "POST /photos タイトルと画像で作成できる" do
    log_in_as(@user)
    assert_difference "Photo.count", +1 do
      post photos_path, params: {
        photo: { title: "ok-title", image: uploaded_fixture("sample_image.png") }
      }
    end
    assert_redirected_to photos_path

    assert_equal "写真をアップロードしました", flash[:notice]

    created_photo = Photo.order(created_at: :desc).first
    assert_equal @user.id, created_photo.user_id
    assert created_photo.image.attached?
  end

  test "POST /photos 異常系: 画像未添付はエラー" do
    log_in_as(@user)
    assert_no_difference "Photo.count" do
      post photos_path, params: { photo: { title: "no-image" } }
    end
    assert_response :unprocessable_entity
    assert_includes response.body, "画像を添付してください"
  end

  private

  def log_in_as(user)
    post login_path, params: { email: user.email, password: user.password, password_confirmation: user.password }
    assert_response :redirect
  end

  def uploaded_fixture(filename, mime = "image/png")
    Rack::Test::UploadedFile.new(file_fixture(filename).to_s, mime)
  end

  def attach_image(photo, filename: "sample_image.png", mime: "image/png")
    photo.image.attach(io: File.open(file_fixture(filename)), filename:, content_type: mime)
  end
end
