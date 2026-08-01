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

  test "owner can soft-delete organization" do
    casting = create_casting_user
    sign_in_as casting[:user]

    delete "/api/v1/organizations/#{casting[:office].id}", as: :json

    assert_response :no_content
    assert_equal "inactive", casting[:office].reload.status
  end

  test "non-owner cannot delete organization" do
    casting = create_casting_user
    agent = create_agent_user
    sign_in_as agent

    delete "/api/v1/organizations/#{casting[:office].id}", as: :json

    assert_response :forbidden
  end

  test "show includes current membership for office member" do
    casting = create_casting_user
    sign_in_as casting[:user]

    get "/api/v1/organizations/#{casting[:office].id}", as: :json

    assert_response :success
    assert_equal "owner", json_response.dig("organization", "current_membership", "membership_role")
  end

  test "index excludes inactive organizations" do
    casting = create_casting_user
    casting[:office].update!(status: "inactive")
    sign_in_as casting[:user]

    get "/api/v1/organizations", as: :json

    assert_response :success
    ids = json_response.fetch("organizations").map { |org| org["id"] }
    assert_not_includes ids, casting[:office].id
  end

  test "agent can create agency and become owner" do
    agent = create_agent_user
    sign_in_as agent

    post "/api/v1/organizations",
      params: {
        organization: {
          name: "New Talent Agency",
          organization_type: "agency",
          city: "Los Angeles",
          state_region: "CA",
          country_code: "US"
        }
      },
      as: :json

    assert_response :created
    organization = Organization.find(json_response.dig("organization", "id"))
    membership = organization.organization_memberships.active.find_by!(user: agent)
    assert_equal "owner", membership.membership_role
    assert_equal "agency", organization.organization_type
  end
end
