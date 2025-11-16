class PhotosController < ApplicationController
  before_action :require_login

  def index
    @photos = Photo.where(user: current_user).with_attached_image.order(created_at: :desc)
    @oauth_connected = session[:oauth_access_token].present?
  end

  def new
    @photo = Photo.new
  end

  def create
    @photo = current_user.photos.new(photo_params)
    if @photo.valid?
      @photo.save
      redirect_to photos_path, notice: "写真をアップロードしました"
    else
      @errors = @photo.errors.full_messages
      render :new, status: 422
    end
  end

  def tweet
    photo = current_user.photos.find(params[:id])
    # FIXME urlをservice側で取得できないので、controller側で取得して渡す
    image_url = url_for(photo.image)

    access_token = session[:oauth_access_token]
    unless access_token
      redirect_to photos_path, alert: "外部サービスと連携してください" and return
    end

    service = PhotoTweetService.new(photo:, image_url:, access_token:)
    response = service.execute
    if response&.is_a?(Net::HTTPCreated)
      redirect_to photos_path, notice: "連携サービスに投稿しました"
    else
      redirect_to photos_path, alert: "連携サービスへの投稿に失敗しました"
    end
  end

  private

  def photo_params
    params.require(:photo).permit(:title, :image)
  end
end
