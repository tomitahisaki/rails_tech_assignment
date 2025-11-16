require "net/http"
require "uri"
require "json"

class PhotoTweetService
  def initialize(photo:, image_url:, access_token:)
    @photo = photo
    @image_url = image_url
    @access_token = access_token
  end

  def execute
    uri = URI.parse("http://unifa-recruit-my-tweet-app.ap-northeast-1.elasticbeanstalk.com/api/tweets")

    http = Net::HTTP.new(uri.host, uri.port)

    request = Net::HTTP::Post.new(uri.request_uri, headers)
    request.body = request_body

    http.request(request)
  rescue => e
    Rails.logger.error "[TweetPhotoService] error: #{e.class} #{e.message}"
    nil # controller 側で nil 判定ができる
  end

  private

  attr_reader :photo, :image_url, :access_token

  def headers
    {
      "Content-Type" => "application/json",
      "Authorization" => "Bearer #{access_token}"
    }
  end

  def request_body
    {
      text: photo.title,
      url: image_url
    }.to_json
  end
end
