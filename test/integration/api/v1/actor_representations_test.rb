require "test_helper"

class Api::V1::ActorRepresentationsTest < ApiTestCase
  setup do
    @actor = create_actor_user
    agency_setup = create_agency_with_divisions
    @agent = agency_setup[:user]
    @agency = agency_setup[:agency]
    @commercial = agency_setup[:divisions][:commercial]
  end

  test "actor can request representation at agency" do
    sign_in_as @actor

    assert_difference "ActorRepresentation.count", 1 do
      post "/api/v1/actor_representations",
        params: {
          actor_representation: {
            organization_id: @agency.id
          }
        },
        as: :json
    end

    assert_response :created
    assert_equal "pending", json_response.dig("actor_representation", "status")
    assert_equal @agency.id, json_response.dig("actor_representation", "organization_id")
  end

  test "actor lists own representations" do
    representation = ActorRepresentation.create!(
      actor_profile: @actor.actor_profile,
      organization: @agency,
      status: "pending",
      started_on: Date.current
    )
    sign_in_as @actor

    get "/api/v1/actor_representations", as: :json

    assert_response :success
    ids = json_response.fetch("actor_representations").map { |record| record["id"] }
    assert_includes ids, representation.id
  end

  test "agent sees roster for their agency" do
    representation = ActorRepresentation.create!(
      actor_profile: @actor.actor_profile,
      organization: @agency,
      status: "active",
      started_on: Date.current,
      confirmed_at: Time.current
    )
    sign_in_as @agent

    get "/api/v1/actor_representations", as: :json

    assert_response :success
    ids = json_response.fetch("actor_representations").map { |record| record["id"] }
    assert_includes ids, representation.id

    get "/api/v1/actor_representations?organization_id=#{@agency.id}", as: :json

    assert_response :success
    assert_equal 1, json_response.fetch("actor_representations").size
    assert_equal representation.id, json_response.dig("actor_representations", 0, "id")
  end

  test "agency owner can activate pending representation" do
    representation = ActorRepresentation.create!(
      actor_profile: @actor.actor_profile,
      organization: @agency,
      status: "pending",
      started_on: Date.current
    )
    sign_in_as @agent

    patch "/api/v1/actor_representations/#{representation.id}",
      params: { actor_representation: { status: "active" } },
      as: :json

    assert_response :success
    representation.reload
    assert_equal "active", representation.status
    assert_not_nil representation.confirmed_at
  end

  test "agency owner can assign division coverage" do
    representation = ActorRepresentation.create!(
      actor_profile: @actor.actor_profile,
      organization: @agency,
      status: "active",
      started_on: Date.current,
      confirmed_at: Time.current
    )
    sign_in_as @agent

    post "/api/v1/actor_representations/#{representation.id}/divisions",
      params: {
        representation_division: {
          division_id: @commercial.id
        }
      },
      as: :json

    assert_response :created
    assert_equal @commercial.id, json_response.dig("representation_division", "division_id")
  end

  test "agency owner can assign designated rep contact" do
    representation = ActorRepresentation.create!(
      actor_profile: @actor.actor_profile,
      organization: @agency,
      status: "active",
      started_on: Date.current,
      confirmed_at: Time.current
    )
    rep_division = representation.actor_representation_divisions.create!(
      division: @commercial,
      status: "active",
      started_on: Date.current
    )
    sign_in_as @agent

    post "/api/v1/actor_representations/#{representation.id}/divisions/#{rep_division.id}/contacts",
      params: {
        contact: {
          representative_profile_id: @agent.representative_profile.id,
          is_primary: true
        }
      },
      as: :json

    assert_response :created
    assert_equal @agent.representative_profile.id,
      json_response.dig("contact", "representative_profile_id")
  end

  test "actor cannot view another actors representation" do
    other_actor = create_actor_user(email: "other-actor@test.example")
    representation = ActorRepresentation.create!(
      actor_profile: other_actor.actor_profile,
      organization: @agency,
      status: "active",
      started_on: Date.current,
      confirmed_at: Time.current
    )
    sign_in_as @actor

    get "/api/v1/actor_representations/#{representation.id}", as: :json

    assert_response :not_found
  end

  test "rejects representation at casting office" do
    casting = create_casting_user
    sign_in_as @actor

    post "/api/v1/actor_representations",
      params: {
        actor_representation: {
          organization_id: casting[:office].id
        }
      },
      as: :json

    assert_response :unprocessable_entity
  end
end
