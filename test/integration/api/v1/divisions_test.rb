require "test_helper"

class Api::V1::DivisionsTest < ApiTestCase
  setup do
    @agent = create_agent_user
    @agency = @agent.organization_memberships.first.organization
    casting = create_casting_user
    @casting_user = casting[:user]
    @office = casting[:office]
  end

  test "agency member can list divisions" do
    Division.create!(organization: @agency, name: "Commercial", slug: "commercial")
    sign_in_as @agent

    get "/api/v1/organizations/#{@agency.id}/divisions", as: :json

    assert_response :success
    assert_equal 1, json_response.fetch("divisions").size
    assert_equal "Commercial", json_response.dig("divisions", 0, "name")
  end

  test "agency owner can create division" do
    owner = User.find_by!(email: @agent.email)
    owner_membership = @agency.organization_memberships.find_by!(user: owner)
    owner_membership.update!(membership_role: "owner") unless owner_membership.membership_role == "owner"

    sign_in_as @agent

    assert_difference "Division.count", 1 do
      post "/api/v1/organizations/#{@agency.id}/divisions",
        params: {
          division: {
            name: "Film and Television",
            description: "Legit theatrical and on-camera"
          }
        },
        as: :json
    end

    assert_response :created
    assert_equal "film-and-television", json_response.dig("division", "slug")
    assert json_response.dig("division", "active")
  end

  test "owner can toggle division active status" do
    division = Division.create!(organization: @agency, name: "Print", slug: "print")
    @agency.organization_memberships.find_by!(user: @agent).update!(membership_role: "owner")
    sign_in_as @agent

    patch "/api/v1/organizations/#{@agency.id}/divisions/#{division.id}",
      params: { division: { active: false } },
      as: :json

    assert_response :success
    assert_not division.reload.active
  end

  test "owner can delete division" do
    division = Division.create!(organization: @agency, name: "Voice-over", slug: "voice-over")
    @agency.organization_memberships.find_by!(user: @agent).update!(membership_role: "owner")
    sign_in_as @agent

    delete "/api/v1/organizations/#{@agency.id}/divisions/#{division.id}", as: :json

    assert_response :no_content
    assert_not Division.exists?(division.id)
  end

  test "rejects duplicate slug within organization" do
    Division.create!(organization: @agency, name: "Commercial", slug: "commercial")
    @agency.organization_memberships.find_by!(user: @agent).update!(membership_role: "owner")
    sign_in_as @agent

    post "/api/v1/organizations/#{@agency.id}/divisions",
      params: { division: { name: "Commercial Two", slug: "commercial" } },
      as: :json

    assert_response :unprocessable_entity
  end

  test "casting office cannot manage divisions" do
    sign_in_as @casting_user

    get "/api/v1/organizations/#{@office.id}/divisions", as: :json

    assert_response :unprocessable_entity
    assert_match(/agencies and management companies/, json_response["error"])
  end

  test "non-admin cannot create division" do
    staff = create_user(email: "staff-agent@test.example")
    staff.create_representative_profile!(representative_type: "agent")
    @agency.organization_memberships.create!(
      user: staff,
      membership_role: "agent",
      status: "active",
      started_on: Date.current,
      accepted_at: Time.current
    )
    sign_in_as staff

    post "/api/v1/organizations/#{@agency.id}/divisions",
      params: { division: { name: "Commercial" } },
      as: :json

    assert_response :forbidden
  end

  test "non-member cannot list divisions" do
    outsider = create_actor_user
    sign_in_as outsider

    get "/api/v1/organizations/#{@agency.id}/divisions", as: :json

    assert_response :forbidden
  end
end
