require "net/http"
require "uri"
require "json"

class OauthController < ApplicationController
  def callback
    code = params[:code]

    access_token = get_access_token(code)
    session[:oauth_access_token] = access_token

    redirect_to photos_path, notice: "外部サービスとの連携が完了しました"
  end

  private

  def get_access_token(code)
    uri = URI("http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/token")

    response = Net::HTTP.post_form(uri, {
      grant_type: "authorization_code",
      code: code,
      redirect_uri: "http://localhost:3000/oauth/callback",
      client_id: Rails.application.credentials.oauth[:client_id],
      client_secret: Rails.application.credentials.oauth[:client_secret]
    })

    body = JSON.parse(response.body)

    body["access_token"]
  end
end
