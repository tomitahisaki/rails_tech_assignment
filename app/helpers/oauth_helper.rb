module OauthHelper
  def oauth_authorize_url
    authorize_url = "http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/oauth/authorize"

    query_params = {
      client_id: Rails.application.credentials.oauth[:client_id],
      response_type: "code",
      redirect_uri: "http://localhost:3000/oauth/callback",
      scope: "write_tweet"
    }.to_query

    "#{authorize_url}?#{query_params}"
  end
end
