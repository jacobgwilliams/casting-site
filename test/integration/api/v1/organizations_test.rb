require "test_helper"

class Api::V1::OrganizationsTest < ApiTestCase
  test "index lists organizations for authenticated user" do
    user = create_casting_user[:user]
    sign_in_as user

    get "/api/v1/organizations", as: :json

    assert_response :success
    assert_operator json_response.fetch("organizations").size, :>=, 1
  end

  test "create organization adds current user as owner" do
    user = create_actor_user
    sign_in_as user

    assert_difference "Organization.count", 1 do
      post "/api/v1/organizations",
        params: {
          organization: {
            name: "New Casting Office",
            organization_type: "casting_office",
            city: "New York",
            state_region: "NY",
            country_code: "US"
          }
        },
        as: :json
    end

    assert_response :created
    organization = Organization.find(json_response.dig("organization", "id"))
    membership = organization.organization_memberships.active.find_by!(user: user)
    assert_equal "owner", membership.membership_role
  end

  test "index requires authentication" do
    get "/api/v1/organizations", as: :json

    assert_response :unauthorized
  end
end
