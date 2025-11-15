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

  private

  def photo_params
    params.require(:photo).permit(:title, :image)
  end
end
