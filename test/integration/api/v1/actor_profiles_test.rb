require "test_helper"

class Api::V1::ActorProfilesTest < ApiTestCase
  test "show returns actor profile for actor user" do
    user = create_actor_user
    sign_in_as user

    get "/api/v1/actor_profile", as: :json

    assert_response :success
    assert_equal user.actor_profile.id, json_response.dig("actor_profile", "id")
    assert_equal "Alex Actor", json_response.dig("actor_profile", "professional_name")
  end

  test "update changes actor profile fields" do
    user = create_actor_user
    sign_in_as user

    patch "/api/v1/actor_profile",
      params: {
        actor_profile: {
          professional_name: "Alexandra A.",
          primary_location: "Los Angeles, CA",
          union_status: "SAG-AFTRA",
          profile_status: "active"
        }
      },
      as: :json

    assert_response :success
    assert_equal "Alexandra A.", json_response.dig("actor_profile", "professional_name")
    assert_equal "Los Angeles, CA", json_response.dig("actor_profile", "primary_location")
  end

  test "show returns not found when user has no actor profile" do
    user = create_agent_user
    sign_in_as user

    get "/api/v1/actor_profile", as: :json

    assert_response :not_found
  end

  test "show requires authentication" do
    get "/api/v1/actor_profile", as: :json

    assert_response :unauthorized
  end
end
