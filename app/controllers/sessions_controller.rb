class SessionsController < ApplicationController
  def new
  end

  def create
    login_service = LoginService.new(login_params)

    if login_service.valid?
      session[:user_id] = login_service.user.id
      redirect_to root_path, notice: "ログインしました"
    else
      flash.now[:alert] = login_service.errors.full_messages.to_sentence
      render :new, status: 422
    end
  end

  def destroy
    reset_session
    redirect_to login_path, notice: "ログアウトしました"
  end

  private

  def login_params
    params.permit(:email, :password)
  end
end
