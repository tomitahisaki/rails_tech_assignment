class PhotosController < ApplicationController
  def index
  @photos = Photo.where(user: current_user).with_attached_image.order(created_at: :desc)
  end
end
