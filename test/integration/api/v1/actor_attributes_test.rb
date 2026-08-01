require "test_helper"

class Api::V1::ActorAttributesTest < ApiTestCase
  setup do
    @actor = create_actor_user
    @profile_attribute = ProfileAttribute.create!(
      name: "Licensed driver",
      slug: "licensed-driver",
      category: "other"
    )
  end

  test "actor lists own attributes" do
    @actor.actor_profile.actor_attributes.create!(
      profile_attribute: @profile_attribute,
      visibility: "public"
    )
    sign_in_as @actor

    get "/api/v1/actor_attributes", as: :json

    assert_response :success
    assert_equal 1, json_response.fetch("actor_attributes").size
    assert_equal "Licensed driver", json_response.dig("actor_attributes", 0, "profile_attribute_name")
  end

  test "actor creates attribute with visibility" do
    sign_in_as @actor

    assert_difference "ActorAttribute.count", 1 do
      post "/api/v1/actor_attributes",
        params: {
          actor_attribute: {
            profile_attribute_id: @profile_attribute.id,
            visibility: "representatives"
          }
        },
        as: :json
    end

    assert_response :created
    assert_equal "representatives", json_response.dig("actor_attribute", "visibility")
  end

  test "actor updates attribute visibility" do
    actor_attribute = @actor.actor_profile.actor_attributes.create!(
      profile_attribute: @profile_attribute,
      visibility: "private"
    )
    sign_in_as @actor

    patch "/api/v1/actor_attributes/#{actor_attribute.id}",
      params: { actor_attribute: { visibility: "casting_only" } },
      as: :json

    assert_response :success
    assert_equal "casting_only", json_response.dig("actor_attribute", "visibility")
  end

  test "actor deletes attribute" do
    actor_attribute = @actor.actor_profile.actor_attributes.create!(
      profile_attribute: @profile_attribute
    )
    sign_in_as @actor

    assert_difference "ActorAttribute.count", -1 do
      delete "/api/v1/actor_attributes/#{actor_attribute.id}", as: :json
    end

    assert_response :no_content
  end
end
