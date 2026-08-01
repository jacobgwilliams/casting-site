require "test_helper"

class Api::V1::BreakdownsTest < ApiTestCase
  setup do
    casting = create_casting_user
    @casting_user = casting[:user]
    @office = casting[:office]
    @project = create_project(casting_user: @casting_user, office: @office)
    @actor = create_actor_user
    @agent = create_agent_user

    @public_breakdown = create_breakdown(
      project: @project,
      created_by_user: @casting_user,
      visibility: "public",
      character_name: "Public Role"
    )
    @rep_only_breakdown = create_breakdown(
      project: @project,
      created_by_user: @casting_user,
      visibility: "representatives_only",
      character_name: "Rep Only Role"
    )
  end

  test "index returns public breakdowns for actors" do
    sign_in_as @actor

    get "/api/v1/breakdowns", as: :json

    assert_response :success
    ids = json_response.fetch("breakdowns").map { |breakdown| breakdown["id"] }
    assert_includes ids, @public_breakdown.id
    assert_not_includes ids, @rep_only_breakdown.id
  end

  test "index returns representatives_only breakdowns for agents" do
    sign_in_as @agent

    get "/api/v1/breakdowns", as: :json

    assert_response :success
    ids = json_response.fetch("breakdowns").map { |breakdown| breakdown["id"] }
    assert_includes ids, @public_breakdown.id
    assert_includes ids, @rep_only_breakdown.id
  end

  test "show returns forbidden when actor requests rep-only breakdown" do
    sign_in_as @actor

    get "/api/v1/breakdowns/#{@rep_only_breakdown.id}", as: :json

    assert_response :forbidden
  end

  test "show returns rep-only breakdown for agent" do
    sign_in_as @agent

    get "/api/v1/breakdowns/#{@rep_only_breakdown.id}", as: :json

    assert_response :success
    assert_equal @rep_only_breakdown.id, json_response.dig("breakdown", "id")
  end
end
