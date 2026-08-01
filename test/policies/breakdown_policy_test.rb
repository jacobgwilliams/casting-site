require "test_helper"

class BreakdownPolicyTest < ActiveSupport::TestCase
  include TestData

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
    @draft_breakdown = create_breakdown(
      project: @project,
      created_by_user: @casting_user,
      visibility: "public",
      status: "draft",
      character_name: "Draft Role",
      published_at: nil
    )
  end

  test "actor can view public published breakdown" do
    assert BreakdownPolicy.new(@actor, @public_breakdown).show?
  end

  test "actor cannot view representatives_only breakdown" do
    assert_not BreakdownPolicy.new(@actor, @rep_only_breakdown).show?
  end

  test "agent can view representatives_only breakdown" do
    assert BreakdownPolicy.new(@agent, @rep_only_breakdown).show?
  end

  test "casting team member can view any published breakdown" do
    assert BreakdownPolicy.new(@casting_user, @rep_only_breakdown).show?
    assert BreakdownPolicy.new(@casting_user, @public_breakdown).show?
  end

  test "actor cannot view unpublished breakdown" do
    assert_not BreakdownPolicy.new(@actor, @draft_breakdown).show?
  end

  test "scope filters breakdowns by visibility rules" do
    breakdowns = Breakdown.includes(:project).order(:character_name)
    visible_to_actor = BreakdownPolicy::Scope.new(@actor, breakdowns).resolve

    assert_includes visible_to_actor, @public_breakdown
    assert_not_includes visible_to_actor, @rep_only_breakdown
    assert_not_includes visible_to_actor, @draft_breakdown
  end
end
