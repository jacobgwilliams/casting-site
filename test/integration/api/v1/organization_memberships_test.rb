require "test_helper"

class Api::V1::OrganizationMembershipsTest < ApiTestCase
  setup do
    casting = create_casting_user
    @casting_user = casting[:user]
    @office = casting[:office]
    @agent = create_agent_user
    @agency = @agent.organization_memberships.first.organization
  end

  test "index lists members for organization members" do
    sign_in_as @casting_user

    get "/api/v1/organizations/#{@office.id}/memberships", as: :json

    assert_response :success
    assert_operator json_response.fetch("memberships").size, :>=, 1
  end

  test "owner can invite member by email" do
    sign_in_as @casting_user

    assert_difference "OrganizationMembership.count", 1 do
      post "/api/v1/organizations/#{@office.id}/memberships",
        params: {
          membership: {
            email: @agent.email,
            membership_role: "staff",
            status: "invited"
          }
        },
        as: :json
    end

    assert_response :created
    membership = OrganizationMembership.find(json_response.dig("membership", "id"))
    assert_equal @agent.id, membership.user_id
    assert_equal "invited", membership.status
  end

  test "agent can self-join agency with invited status" do
    new_agency = Organization.create!(
      name: "Open Agency",
      organization_type: "agency",
      status: "active"
    )
    sign_in_as @agent

    post "/api/v1/organizations/#{new_agency.id}/memberships",
      params: {
        membership: {
          membership_role: "agent"
        }
      },
      as: :json

    assert_response :created
    assert_equal "invited", json_response.dig("membership", "status")
    assert_equal @agent.id, json_response.dig("membership", "user_id")
  end

  test "self-join rejects invalid role for organization type" do
    sign_in_as @agent

    post "/api/v1/organizations/#{@office.id}/memberships",
      params: {
        membership: {
          membership_role: "agent"
        }
      },
      as: :json

    assert_response :unprocessable_entity
  end

  test "invited member can accept membership" do
    membership = @office.organization_memberships.create!(
      user: @agent,
      membership_role: "staff",
      status: "invited",
      started_on: Date.current,
      invited_at: Time.current
    )
    sign_in_as @agent

    patch "/api/v1/organizations/#{@office.id}/memberships/#{membership.id}",
      params: { membership: { status: "active" } },
      as: :json

    assert_response :success
    assert_equal "active", membership.reload.status
    assert_not_nil membership.accepted_at
  end

  test "owner can remove member" do
    membership = @office.organization_memberships.create!(
      user: @agent,
      membership_role: "staff",
      status: "active",
      started_on: Date.current,
      accepted_at: Time.current
    )
    sign_in_as @casting_user

    delete "/api/v1/organizations/#{@office.id}/memberships/#{membership.id}", as: :json

    assert_response :no_content
    assert_equal "removed", membership.reload.status
  end

  test "non-member cannot list memberships" do
    outsider = create_actor_user
    sign_in_as outsider

    get "/api/v1/organizations/#{@office.id}/memberships", as: :json

    assert_response :forbidden
  end

  test "non-admin cannot invite members" do
    member = create_casting_user(email: "associate@test.example")
    @office.organization_memberships.create!(
      user: member[:user],
      membership_role: "casting_director",
      status: "active",
      started_on: Date.current,
      accepted_at: Time.current
    )
    sign_in_as member[:user]

    post "/api/v1/organizations/#{@office.id}/memberships",
      params: {
        membership: {
          email: @agent.email,
          membership_role: "staff"
        }
      },
      as: :json

    assert_response :forbidden
  end

  test "member can leave office" do
    membership = @office.organization_memberships.create!(
      user: @agent,
      membership_role: "staff",
      status: "active",
      started_on: Date.current,
      accepted_at: Time.current
    )
    sign_in_as @agent

    delete "/api/v1/organizations/#{@office.id}/memberships/#{membership.id}", as: :json

    assert_response :no_content
    assert_equal "removed", membership.reload.status
  end

  test "owner can promote staff to casting director when persona matches" do
    casting_professional = create_user(
      email: "associate@test.example",
      first_name: "Jamie",
      last_name: "Associate"
    )
    casting_professional.create_casting_professional_profile!
    membership = @office.organization_memberships.create!(
      user: casting_professional,
      membership_role: "staff",
      status: "active",
      started_on: Date.current,
      accepted_at: Time.current
    )
    sign_in_as @casting_user

    patch "/api/v1/organizations/#{@office.id}/memberships/#{membership.id}",
      params: { membership: { membership_role: "casting_director" } },
      as: :json

    assert_response :success
    assert_equal "casting_director", membership.reload.membership_role
  end

  test "owner can update staff job title" do
    membership = @office.organization_memberships.create!(
      user: @agent,
      membership_role: "staff",
      status: "active",
      started_on: Date.current,
      accepted_at: Time.current
    )
    sign_in_as @casting_user

    patch "/api/v1/organizations/#{@office.id}/memberships/#{membership.id}",
      params: { membership: { job_title: "Front desk" } },
      as: :json

    assert_response :success
    assert_equal "Front desk", membership.reload.job_title
  end

  test "invited member cannot change role when accepting" do
    membership = @office.organization_memberships.create!(
      user: @agent,
      membership_role: "staff",
      status: "invited",
      started_on: Date.current,
      invited_at: Time.current
    )
    sign_in_as @agent

    patch "/api/v1/organizations/#{@office.id}/memberships/#{membership.id}",
      params: { membership: { status: "active", membership_role: "owner" } },
      as: :json

    assert_response :success
    membership.reload
    assert_equal "active", membership.status
    assert_equal "staff", membership.membership_role
  end

  test "agent role requires agent profile" do
    actor = create_actor_user
    new_agency = Organization.create!(
      name: "Another Agency",
      organization_type: "agency",
      status: "active"
    )
    sign_in_as actor

    post "/api/v1/organizations/#{new_agency.id}/memberships",
      params: { membership: { membership_role: "agent" } },
      as: :json

    assert_response :unprocessable_entity
  end
end
