require "test_helper"

class Api::V1::ProfileAttributesTest < ApiTestCase
  test "lists profile attribute catalog without authentication" do
    ProfileAttribute.create!(name: "Height", slug: "height", category: "physical")

    get "/api/v1/profile_attributes", as: :json

    assert_response :success
    names = json_response.fetch("profile_attributes").map { |record| record["name"] }
    assert_includes names, "Height"
  end
end
