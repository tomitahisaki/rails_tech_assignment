require "test_helper"
require "minitest/mock"

class PhotoTweetServiceTest < ActiveSupport::TestCase
  class FakeHTTP
    attr_reader :requests

    def initialize(response)
      @response = response
      @requests = []
    end

    def request(req)
      @requests << req
      @response
    end
  end

  test "execute: 正しいJSONとヘッダーでPOSTされる" do
    photo = Photo.new(title: "Test Photo")
    image_url = "http://example.com/image.png"
    token = "abc123"

    service = PhotoTweetService.new(photo: photo, image_url: image_url, access_token: token)

    # 返したい偽の response
    fake_response = Net::HTTPOK.new("1.1", "200", "OK")
    fake_http = FakeHTTP.new(fake_response)

    Net::HTTP.stub :new, fake_http do
      response = service.execute

      assert_equal fake_response, response

      req = fake_http.requests.first

      assert_equal "application/json", req["Content-Type"]
      assert_equal "Bearer #{token}",  req["Authorization"]

      expected_body = {
        text: "Test Photo",
        url:  image_url
      }.to_json

      assert_equal expected_body, req.body
    end
  end
end
