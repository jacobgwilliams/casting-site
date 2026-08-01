require "test_helper"

class Api::V1::Me::MembershipsTest < ApiTestCase
  test "index returns current user memberships with organizations" do
    casting = create_casting_user
    sign_in_as casting[:user]

    get "/api/v1/me/memberships", as: :json

    assert_response :success
    memberships = json_response.fetch("memberships")
    assert_operator memberships.size, :>=, 1
    assert memberships.first.key?("organization")
    assert_equal casting[:office].id, memberships.first.dig("organization", "id")
  end

  test "index requires authentication" do
    get "/api/v1/me/memberships", as: :json

    assert_response :unauthorized
  end

  test "index excludes removed memberships" do
    casting = create_casting_user
    removed = casting[:office].organization_memberships.create!(
      user: create_actor_user(email: "former@test.example"),
      membership_role: "staff",
      status: "removed",
      started_on: Date.current,
      ended_on: Date.current
    )
    sign_in_as casting[:user]

    get "/api/v1/me/memberships", as: :json

    assert_response :success
    ids = json_response.fetch("memberships").map { |membership| membership["id"] }
    assert_not_includes ids, removed.id
  end
end
