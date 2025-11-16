require "test_helper"
require "minitest/mock"

# テスト用に OauthController#get_access_token を上書きする
class ::OauthController
  private

  def get_access_token(code)
    # 本番では外部APIを叩いていたが、
    # テストでは固定値を返すようにする
    "dummy-token-123"
  end
end

class PhotosControllerTest < ActionDispatch::IntegrationTest
  def setup
    @user = User.create!(
      email: "test@example.com",
      password: "password123",
      password_confirmation: "password123"
    )

    @photo = Photo.new(title: "Test Photo", user: @user)
    attach_image(@photo)
    @photo.save!
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

  test "POST /photos/:id/tweet 成功系: 201なら成功メッセージを表示" do
    log_in_as(@user)
    # access_token をセッションにセットするために OAuth コールバックを実行
    get oauth_callback_path, params: { code: "auth-code-xyz" }

    fake_response = Net::HTTPCreated.new("1.1", "201", "Created")

    # execute だけ持ったシンプルな偽サービスオブジェクト
    fake_service = Object.new
    def fake_service.execute
      @response
    end
    fake_service.instance_variable_set(:@response, fake_response)

    PhotoTweetService.stub :new, ->(*args, **kwargs) { fake_service } do
      post tweet_photo_path(@photo)

      assert_redirected_to photos_path

      follow_redirect! # redirect先に移動
      assert_includes response.body, "連携サービスに投稿しました"
    end
  end

  test "POST /photos/:id/tweet 異常系: access_token が無い場合は連携を促すメッセージ" do
    log_in_as(@user)
    # OAuth callback を呼ばない → session[:oauth_access_token] は nil のまま

    post tweet_photo_path(@photo)

    assert_redirected_to photos_path

    follow_redirect!
    assert_includes response.body, "外部サービスと連携してください"
  end

  test "POST /photos/:id/tweet 異常系: サービスが201以外なら失敗メッセージ" do
    log_in_as(@user)
    # OAuth 連携して access_token セット
    get oauth_callback_path, params: { code: "auth-code-xyz" }

    fake_response = Net::HTTPBadRequest.new("1.1", "400", "Bad Request")

    fake_service = Object.new
    def fake_service.execute
      @response
    end
    fake_service.instance_variable_set(:@response, fake_response)

    PhotoTweetService.stub :new, ->(*args, **kwargs) { fake_service } do
      post tweet_photo_path(@photo)

      assert_redirected_to photos_path

      follow_redirect!
      assert_includes response.body, "連携サービスへの投稿に失敗しました"
    end
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
